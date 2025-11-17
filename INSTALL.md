# Install instructions

Please ensure you have OCaml installed and a recent version of opam initialized.
If you need to install Ocaml and initialize opam run:

- bash -c "sh <(curl -fsSL https://opam.ocaml.org/install.sh)"
- opam init

Please also ensure you have dune installed with the following command:

- opam install dune

You will need to install raylib with the following command:

- opam install raylib

Now, just the game with the following command:

- dune exec bin/main.exe
