# Install instructions

Please ensure you have OCaml installed and a recent version of opam initialized.

If you need to install Ocaml and initialize opam run:

- bash -c "sh <(curl -fsSL https://opam.ocaml.org/install.sh)"

You should run all of the following in the cameldew-valley directory:

- opam init

Please also ensure you have dune installed with the following command:

- opam install dune

If you do not have homebrew installed, please install it before running the following commands, and make sure it is added to your PATH using the commands it gives you after installation.

- /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Then install pkg-config using homebrew with the following command:

- brew install pkg-config sqlite

You will also need to install raylib and sqlite3 with the following commands:

- opam install ounit2
- opam install raylib
- opam install sqlite3

If you are prompted to install any other dependencies while installing sqlite3, just hit "1" in the terminal, and they should install.

Now, just the start game with the following command:

- dune exec bin/main.exe
