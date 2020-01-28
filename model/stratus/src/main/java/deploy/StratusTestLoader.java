package deploy;

import io.ciera.runtime.instanceloading.generic.IGenericLoader;
import io.ciera.runtime.instanceloading.generic.util.LOAD;
import io.ciera.runtime.summit.exceptions.XtumlException;

import deploy.stratus.type.EnumerateItem;

public class StratusTestLoader implements IGenericLoader {

    public void load(LOAD loader, String[] args) {
        System.out.println("Starting load.");
        try {
            Object e = loader.create("EnumerateItem");
            loader.set_attribute(e, "index", 5);
            loader.set_attribute(e, "name", "test_name");
            System.out.printf("e.index: %d\n", ((EnumerateItem)e).getIndex());
            System.out.printf("e.name: %s\n", ((EnumerateItem)e).getName());
            Object return_value = loader.call_function("test_function", 7, "object of field type");
            System.out.printf("return value: %s\n", return_value);
        }
        catch (XtumlException e) {
            e.printStackTrace();
        }
        System.out.println("Done with load.");
    }

}
