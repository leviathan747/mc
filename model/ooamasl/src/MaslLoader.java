import java.io.*;

public class MaslLoader implements LOAD {
    private PrintStream output;
    private Object current_object;

    public MaslLoader() {
        output = System.out;
        current_object = new Object();
    }

    public Object create(String key_letters) throws XtumlException {
        output.println( "create object instance i of " + key_letters );
        return current_object;
    }
    public void load(String java_class, String[] args) throws XtumlException {
        output.println( "load" );
    }
    public void relate(Object form, Object part, int rel_num, String phrase) throws XtumlException {
        output.println( "relate form to part across R" + rel_num + "." + phrase );
    }
    public void relate_using(Object form, Object part, Object link, int rel_num, String phrase) throws XtumlException {
        output.println( "relate_using" );
    }
    public void set_attribute(Object instance, String attribute_name, Object value) throws XtumlException {
        output.println( "set_attribute " + current_object + "." + attribute_name + " = " + value );
    }
    public Object select(String key_letters, String name) throws XtumlException {
        output.println( "select any i from instances of " + key_letters + " where ( selected.name == " + name + " )" );
        return current_object;
    }
}