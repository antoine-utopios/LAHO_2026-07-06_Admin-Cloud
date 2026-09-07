package fr.gharrowbm.springapitestingnosecurity.exceptions;

public class ElementNotFoundException extends RuntimeException {
    public ElementNotFoundException(String element, Object id) {
        super(String.format("Element %s not found with id %s", element, id));
    }
}
