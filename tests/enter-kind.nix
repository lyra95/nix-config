{
  runCommand,
  bash,
  coreutils,
}:
runCommand "enter-kind-test" {nativeBuildInputs = [bash coreutils];} ''
  bash ${./enter-kind.sh} ${../modules/home-manager/enter-kind.sh}
  touch "$out"
''
