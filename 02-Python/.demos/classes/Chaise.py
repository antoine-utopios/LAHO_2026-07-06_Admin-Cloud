class Chaise:
    nombre_pieds: int
    materiau: str
    couleur: str

    def __init__(self, nombre_pieds: int, materiau: str, couleur: str):
        self.nombre_pieds = nombre_pieds
        self.materiau = materiau
        self.couleur = couleur