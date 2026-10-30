FROM registry.redhat.io/rhel10/rhel-bootc:latest

RUN dnf -y install tmux mkpasswd firefox unzip && \
    dnf group install -y --allowerasing GNOME Fonts && \
    dnf remove -y gnome-initial-setup gnome-tour && \
    dnf clean all

RUN pass=$(mkpasswd --method=SHA-512 --rounds=4096 redhat) && useradd -m -G wheel redhat -p $pass
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo

RUN systemctl set-default graphical.target

# Download dash-to-dock to /usr for tmpfiles provisioning
RUN mkdir -p /usr/share/dash-to-dock && \
    curl -L https://github.com/micheleg/dash-to-dock/releases/download/extensions.gnome.org-v103/dash-to-dock@micxgx.gmail.com.zip \
        -o /tmp/dash-to-dock.zip && \
    unzip /tmp/dash-to-dock.zip -d /usr/share/dash-to-dock && \
    rm /tmp/dash-to-dock.zip

COPY usr/ usr/

COPY etc/ etc/

COPY train-tickets-departures.container /usr/share/containers/systemd/train-tickets-departures.container

RUN mkdir -p /usr/lib/bootc/bound-images.d && \
    ln -s /usr/share/containers/systemd/train-tickets-departures.container \
        /usr/lib/bootc/bound-images.d/train-tickets-departures.container

RUN dconf update

COPY --chmod=644 kiosk_autostart.desktop /usr/share/kiosk/kiosk_autostart.desktop

RUN firewall-offline-cmd --zone=public --add-port=8080/tcp
