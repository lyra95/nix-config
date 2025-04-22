FROM nixos/nix:2.28.2

RUN mkdir -p /root/nixos
COPY . /root/nixos

RUN echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf

WORKDIR /root/nixos
RUN nix build .#homeConfigurations.container.activationPackage
RUN nix-env -q | xargs nix-env --set-flag priority 0
RUN ./result/activate

WORKDIR /root
ENTRYPOINT ["bash"]

