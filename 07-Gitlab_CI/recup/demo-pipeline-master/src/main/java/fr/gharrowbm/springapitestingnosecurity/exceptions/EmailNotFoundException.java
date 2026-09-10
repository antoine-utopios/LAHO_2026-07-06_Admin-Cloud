package fr.gharrowbm.springapitestingnosecurity.exceptions;

public class EmailNotFoundException extends  RuntimeException {
    public EmailNotFoundException(String email) {
        super(String.format("Email '%s' not found", email));
    }
}
