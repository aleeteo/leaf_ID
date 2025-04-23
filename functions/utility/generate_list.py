import os
import sys


def generate_list(directory, output_file):
    """Genera un file .list con i nomi dei file in una directory, escludendo .DS_Store."""
    with open(output_file, "w") as f:
        for file in sorted(os.listdir(directory)):
            if file != ".DS_Store":
                f.write(file + "\n")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python3 generate_list.py <directory> <output_file>")
        sys.exit(1)

    directory = sys.argv[1]
    output_file = sys.argv[2]
    generate_list(directory, output_file)
