T_b("    ");
T_b("private ");
T_b(set_name);
T_b(" ");
T_b(self->class_name);
T_b("_extent;");
T_b("\n");
T_b("    ");
T_b("public ");
T_b(set_name);
T_b(" ");
T_b(self->name);
T_b("() throws XtumlException {");
T_b("\n");
T_b("        ");
T_b("return ");
T_b(self->class_name);
T_b("_extent.toImmutableSet();");
T_b("\n");
T_b("    ");
T_b("}");
T_b("\n");