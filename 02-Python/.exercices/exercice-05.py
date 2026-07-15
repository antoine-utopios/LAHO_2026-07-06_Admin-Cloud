from random import randint

nombre_mystere = randint(1, 5)

while True:
    choix_utilisateur = int(input("Votre choix: "))

    if choix_utilisateur == nombre_mystere:
        print("Bravo, vous avez gagné !")
        break
    else:
        print("Désolé, c'était pas le bon gobelet !")

        gobelets = [None] * 5

        for i in range(5):
            if i == nombre_mystere - 1:
                gobelets[i] = "0"
            else:
                gobelets[i] = ""

        print(gobelets)

        nombre_mystere = randint(1, 5)
