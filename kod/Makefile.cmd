pushd %~p0
..\narzedzia\nesasm3 snek.asm
pause
..\narzedzia\emulator\fceux64 snek.nes
popd