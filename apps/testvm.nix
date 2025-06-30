{ pkgs }:
{
  type = "app";
  meta.description = "management script for test VMs";
  program = pkgs.writeShellApplication {
    name = "launch-testvm";
    runtimeInputs = [
      pkgs.gum
      pkgs.qemu
      pkgs.OVMF
    ];
    text = ''
      set -e

      build_image() {
        rm -f result "$DISK"
        rm -f "$DISK"
        gum spin --title "building generation script..." --show-output \
        -- nix build .#nixosConfigurations.testvm.config.system.build.diskoImagesScript
        echo "done. executing script to build image..."
        ./result --post-format-files ~/.config/sops/age/keys.txt /home/lcwllmr/.config/sops/age/keys.txt
      }

      CPUS="4"
      RAM="4G"
      DISK="testvm.raw"

      launch_vm() {
        local graphical_mode="$1"
        EXTRA_QEMU_FLAGS=()
        if "$graphical_mode"; then
          EXTRA_QEMU_FLAGS+=("-display" "gtk")
          EXTRA_QEMU_FLAGS+=("-device" "virtio-vga")
        else
          EXTRA_QEMU_FLAGS+=("-display" "none")
          EXTRA_QEMU_FLAGS+=("-daemonize")
        fi

        qemu-system-x86_64 \
          -enable-kvm \
          -cpu host -smp "$CPUS" -m "$RAM" \
          -netdev user,id=net0,hostfwd=tcp::2222-:22 \
          -device virtio-net-pci,netdev=net0 \
          -drive if=pflash,format=raw,readonly=on,file=${pkgs.OVMF.firmware} \
          -drive if=pflash,format=raw,readonly=on,file=${pkgs.OVMF.variables} \
          -virtfs local,path="$(pwd)",mount_tag=flake,security_model=passthrough \
          -drive "if=virtio,format=raw,file=$DISK" \
          -pidfile ./pidfile "''${EXTRA_QEMU_FLAGS[@]}" &
        disown

        sleep 1
      }

      while true
      do
        echo "STATUS:"
        OPTS=("quit")
        if [ -f "pidfile" ]; then
          echo "  vm running under pid" "$(<pidfile)"
          OPTS+=("ssh into vm")
          OPTS+=("kill vm")
        else
          echo "  vm not running"
          if [ ! -f "$DISK" ]; then
            echo "  no disk image found"
            OPTS+=("build disk image")
          else
            echo "  disk image found: $DISK"
            OPTS+=("rebuild disk image")
            OPTS+=("launch daemonized vm")
            OPTS+=("launch graphical vm")
          fi
        fi

        CMD=$(gum choose --header "what to do next?" "''${OPTS[@]}")
        case "$CMD" in
          "quit")
            exit 0
            ;;
          "ssh into vm")
            echo "$CMD"
            gum spin --title "waiting for ssh server to start..." --show-output \
            -- ssh -p 2222 lcwllmr@localhost true
            ssh -p 2222 lcwllmr@localhost
            ;;
          "kill vm")
            echo "$CMD"
            kill "$(<pidfile)"
            rm -f ./pidfile
            ;;
          "build disk image" | "rebuild disk image")
            build_image
            ;;
          "launch daemonized vm")
            launch_vm false
            ;;
          "launch graphical vm")
            launch_vm true
            ;;
        esac
      done
    '';
  };
}
