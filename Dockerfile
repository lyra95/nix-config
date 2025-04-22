FROM nixos/nix:2.28.2

RUN echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf
RUN nix-env -q | xargs nix-env --set-flag priority 0

RUN mkdir -p /root/nixos
COPY . /root/nixos

WORKDIR /root/nixos
RUN nix build .#homeConfigurations.container.activationPackage && ./result/activate && nix-collect-garbage -d

WORKDIR /root
ENTRYPOINT ["bash"]

