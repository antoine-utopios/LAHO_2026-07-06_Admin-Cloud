class Mammal:
    # Attribut de classe
    mammal_counter = 0
    
    # Attribut d'objet
    id: int
    nombre_pattes: int
    nom: str
    race: str
    couleur: str

    def __init__(self, nombre_pattes: int, nom: str, race: str, couleur: str):
        # Modification de l'attribut de classe (commun à tous les éléments de cette classe)
        Mammal.mammal_counter += 1
        # Fixation de l'ID de l'instance en court de création à partir de la valeur actuelle de l'attribut de classe
        self.id = Mammal.mammal_counter

        self.couleur = couleur
        self.nombre_pattes = nombre_pattes
        self.nom = nom
        self.race = race

    def __str__(self):
        return f"Le Mammifère de race '{self.race}' s'appelle '{self.nom}', il est de couleur '{self.couleur}' et possède '{self.nombre_pattes}' patte(s)"
    
    def __eq__(self, value):
        return self.id == value.id
    
    def crier(self):
        print(f"{self.nom} crie !")

class Dog(Mammal):
    jouets: list[str]

    def __init__(self, nombre_pattes, nom, couleur, jouets):
        super().__init__(nombre_pattes, nom, "Canis Familiaris", couleur)
        self.jouets = jouets
    
    def crier(self):
        print("Woof woof !")

class Cat(Mammal):
    nombre_victimes: int

    def __init__(self, nombre_pattes, nom, couleur):
        super().__init__(nombre_pattes, nom, "Felis Felidae", couleur)
        self.nombre_victimes = 0

    def massacrer(self, nom_victime):
        print("MIAOU! *donne un coup de couteau*")
        self.nombre_victimes += 1
        print(f"{nom_victime} a succombé...")

    def crier(self):
        print("Miaou miaou (Je vais tuer ta famille) !")