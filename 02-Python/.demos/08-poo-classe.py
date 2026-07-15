from classes.Chaise import Chaise
from classes.Animal import Mammal, Dog, Cat

# class train_electrique
class TrainElectrique:
    pass

chaise_a = Chaise(4, "Bois", "Vert")

chaise_b = Chaise(6, "Métal", "Bleu")

chaise_b.toto = "Blabla"

print(type(chaise_a))
print(type(chaise_b.toto))
print(chaise_a.couleur)

toto = Mammal(4, "Berlioz", "Felis Felidae", "Orange")

tata = Mammal(4, "Salakis", "Felis Felidae", "Orange")
bidule = Mammal(4, "Berlioz", "Felis Felidae", "Orange")
bidule = Mammal(4, "Berlioz", "Felis Felidae", "Orange")
bidule = Mammal(4, "Berlioz", "Felis Felidae", "Orange")

print(toto.id)
print(tata.id)
print(Mammal.mammal_counter)
print(toto == tata)

# date_brute = input("Donnez moi une date au format DD/MM/YYYY")
# jour, mois, annee = date_brute.split('/')

def crier_fct(nom_animal):
    print(f"{nom_animal} crie !")

crier_fct("Leo")
crier_fct("Rex")

toto.crier()
tata.crier()

rex = Dog(4, "Rex", "Feu / Noir", ["Balle", "Balle mâchée", "Balle rebondissante"])

print(rex.nom)
print(rex.race)
rex.crier()

sushi = Cat(4, "Sushi", "Orange")

print(sushi.nom)
print(sushi.race)
sushi.crier()
sushi.massacrer("Alexandre")
print(sushi.nombre_victimes)

liste_mammals: list[Mammal] = [
    toto,
    tata,
    bidule,
    rex,
    sushi
]

# Polymorphisme
for mammal in liste_mammals:
    mammal.crier()