import argparse

parser = argparse.ArgumentParser(description="Script Python servant à faire des opération mathématiques de base")
parser.add_argument("-m", "--mode", metavar="mode", required=True, choices=["sum", "sub", "mul", "div"], help="Le mode du calcul.")
parser.add_argument("-v", "--verbose", metavar="verbose", default="false", help="Afficher l'opération complète.")

arguments = parser.parse_args()

nb_a = int(input("Veuillez entrer le nombre A: "))
nb_b = int(input("Veuillez entrer le nombre B: "))

match arguments.mode: 
  case "sum":
    if arguments.verbose == "true":
      details = f"{nb_a} + {nb_b} " 
    else:
      details = "" 
    result = nb_a + nb_b
  case "sub":
    details = f"{nb_a} - {nb_b} " if arguments.verbose == "true" else ""
    result = nb_a - nb_b
  case "mul":
    details = f"{nb_a} x {nb_b} " if arguments.verbose == "true" else ""
    result = nb_a * nb_b
  case "div":
    details = f"{nb_a} / {nb_b} " if arguments.verbose == "true" else ""
    result = nb_a / nb_b

print(f"Le résultat de l'opération {details}vaut {result}")