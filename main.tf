provider "google" {
  project = "your-project-id"
  region  = "us-central1"
}

resource "google_compute_instance" "sftp_server" {
  name         = "sftp-server"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network       = "default"
    access_config {
      // Allocates an external IP
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y openssh-server
    mkdir -p /var/sftp/uploads
    groupadd sftpusers
    useradd -m -d /home/sftpuser -s /usr/sbin/nologin -G sftpusers sftpuser
    echo 'sftpuser:password' | chpasswd
    chown root:root /var/sftp
    chmod 755 /var/sftp
    chown sftpuser:sftpusers /var/sftp/uploads
    echo 'Match Group sftpusers' >> /etc/ssh/sshd_config
    echo '    ChrootDirectory /var/sftp' >> /etc/ssh/sshd_config
    echo '    ForceCommand internal-sftp' >> /etc/ssh/sshd_config
    echo '    AllowTcpForwarding no' >> /etc/ssh/sshd_config
    echo '    X11Forwarding no' >> /etc/ssh/sshd_config
    systemctl restart sshd
  EOT
}

resource "google_compute_firewall" "allow_sftp" {
  name    = "allow-sftp"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "sftp_static_ip" {
  name = "sftp-static-ip"
}
