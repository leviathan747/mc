tree grammar MaslWalker;

options
{
  tokenVocab=MaslParser;
  ASTLabelType=CommonTree;
}

/*
scope NameScope
{
  NameLookup lookup;
}

scope WhereClauseScope
{
  ObjectDeclaration parentObject;
}
*/

@header
{
import java.io.*;
}

@annotations
{
@SuppressWarnings("all")
}

@members
{
// external interface
private Serial serial = null;
private LOAD loader = null;
private Object current_supertype = null;
private Object current_attribute = null;
private Object current_domain = null;
private Object current_object = null;
private Object current_project = null;
private Object current_service = null;
private Object current_terminator = null;
private Object current_type = null;

// parent masl parser
private MaslImportParser masl_parser = null;

// argument array to pass to interface
private String[] args = new String[8];

// set the serial interface
public void setInterface ( Serial serial, LOAD loader ) {
    if ( serial != null )
        this.serial = serial;
    else
        this.serial = null;
    if ( loader != null )
        this.loader = loader;
    else
        this.loader = null;

    // fill args initially with empty strings
    for ( int i = 0; i < args.length; i++ ) args[i] = "";
}

// set the parent masl parser
public void setMaslParser( MaslImportParser p ) {
    if ( p != null )
        this.masl_parser = p;
    else
        this.masl_parser = null;
}

// call to the interface with null checking
private void populate( String classname, String[] args ) {
    // check args and interface
    if ( classname == null || args == null ) {
        System.err.println( "Invalid arguments." );
        return;
    }
    if ( serial == null ) {
        System.err.println( "No external interface set." );
        return;
    }

    // call the interface
    serial.populate( classname, args );

    // fill args with empty strings
    for ( int i = 0; i < args.length; i++ ) args[i] = "";
}

// get the current file
private String getFile() {
    if ( null == masl_parser ) return null;
    File f = new File( masl_parser.getFile() );
    return f.getName();
}

}

target                        : definition+;

definition                    : projectDefinition
                              | domainDefinition
                              ;


//---------------------------------------------------------
// Project Definition
//---------------------------------------------------------

identifier
returns [String name]
                              : Identifier                  {
                                                              $name = $Identifier.text;
                                                            }
                              ;


projectDefinition
returns [Object project]

                              : ^( PROJECT
                                   projectName              {
                                                              args[0] = $projectName.name;
                                                              populate( "project", args );
                                                              try {
                                                                $project = loader.create( "Project" );
                                                                loader.set_attribute( $project, "name", $projectName.name );
                                                              } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   description
                                   ( projectDomainDefinition
                                                            {
                                                              try {
                                                                loader.relate( $projectDomainDefinition.domain, $project, 5900, "" );
                                                              } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   )*
                                   pragmaList[""])              
                                                            {
                                                              populate( "project", args );  // end project
                                                            }

                              ;

projectDomainDefinition
returns [Object domain]
                              : ^( DOMAIN
                                   projectDomainReference   
                                                            {
                                                                args[0] = $projectDomainReference.ref;
                                                                populate( "domain", args );
                                                                try {
                                                                  $domain = loader.create( "ProjectDomain" );
                                                                  loader.set_attribute( $domain, "name", $projectDomainReference.ref );
                                                                } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   description
                                   ( projectTerminatorDefinition    
                                                            {
                                                              try {
                                                                loader.relate( $projectTerminatorDefinition.terminator, $domain, 5902, "" );
                                                              } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   )*
                                   pragmaList[""]               
                                 )                          
                                                            {
                                                                populate( "domain", args ); // end domain
                                                            }
                              ;


projectName
returns [String name]
                              :^( PROJECT_NAME
                                   identifier               { $name = $identifier.name; }
                                )
                              ;


//---------------------------------------------------------
// Domain Definition
//---------------------------------------------------------

domainDefinition
returns [Object domain]
                                                                                             
                              : ^( DOMAIN
                                   domainName               {
                                                                args[0] = $domainName.name;
                                                                populate( "domain", args );
                                                                try {
                                                                  $domain = loader.create( "Domain" );
                                                                  loader.set_attribute( $domain, "name", $domainName.name );
                                                                } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   description
                                   ( objectDeclaration           
                                                            {
                                                              try {
                                                                loader.relate( $objectDeclaration.object, $domain, 5805, "" );
                                                              } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   | domainServiceDeclaration    
                                                            {
                                                              try {
                                                                loader.relate( $domainServiceDeclaration.domainservice, $domain, 5303, "" );
                                                              } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   | domainTerminatorDefinition    
                                                            {
                                                              try {
                                                                loader.relate( $domainTerminatorDefinition.terminator, $domain, 5304, "" );
                                                              } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   | relationshipDefinition     
                                                            {
                                                              try {
                                                                loader.relate( $relationshipDefinition.relationship, $domain, 6003, "" );
                                                              } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   | objectDefinition            
                                                            {
                                                              try {
                                                                loader.relate( $objectDefinition.object, $domain, 5805, "" );
                                                              } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   | typeDeclaration             
                                                            {
                                                              try {
                                                                loader.relate( $typeDeclaration.type, $domain, 6235, "" );
                                                              } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   | typeForwardDeclaration             
                                                            {
                                                              try {
                                                                loader.relate( $typeForwardDeclaration.type, $domain, 6235, "" );
                                                              } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   | exceptionDeclaration        
                                                            {
                                                              try {
                                                                loader.relate( $exceptionDeclaration.rejection, $domain, 5400, "" );
                                                              } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   )*
                                   pragmaList[""]                    
                                 )                              
                                                            {
                                                                populate( "domain", args );
                                                            }
                              ;

domainName
returns [String name]
                              : ^( DOMAIN_NAME
                                   identifier               { $name = $identifier.name; }
                                 )
                              ;

domainReference
returns [String ref]
                              : domainName                  { $ref = $domainName.name; }
                              ;


projectDomainReference
returns [String ref]
                              : domainName                  { $ref = $domainName.name; }
                              ;



optionalDomainReference
returns [String ref, boolean defaulted]
                              : domainReference             { $ref = $domainReference.ref; $defaulted = false; }
                              | /* blank */                 { $ref = ""; $defaulted = true;}
                              ;



//---------------------------------------------------------
// Exception Declaration
//---------------------------------------------------------
exceptionDeclaration
returns [Object rejection]
                              : ^( EXCEPTION
                                   exceptionName            
                                   exceptionVisibility      
                                                              {
                                                                  args[0] = $exceptionName.name;
                                                                  args[1] = $exceptionVisibility.visibility;
                                                                  populate( "exception", args );
                                                                  try {
                                                                    $rejection = loader.create( "ExceptionDeclaration" );
                                                                    loader.set_attribute( $rejection, "name", $exceptionName.name );
                                                                    loader.set_attribute( $rejection, "visibility", "Visibility::" + $exceptionVisibility.visibility );
                                                                  } catch ( XtumlException e ) { System.err.println( e ); }
                                                              }
                                   pragmaList[""]               
                                 )                          
                                                              {
                                                                  populate( "exception", args );    // end exception
                                                              }
                              ;

exceptionName
returns [ String name ]
                              : ^( EXCEPTION_NAME
                                   identifier)              { $name = $identifier.name; }
                              ;

exceptionReference
returns [String ref]
                              : optionalDomainReference
                                exceptionName               
                                                              {
                                                                  try {
                                                                    Object er = loader.create( "ExceptionReference" );
                                                                    // CDS - consider selecting through optionalDomainReference
                                                                    Object e = loader.select( "ExceptionDeclaration", $exceptionName.name );
                                                                    loader.relate( er, e, 5402, "" );
                                                                  } catch ( XtumlException e ) { System.err.println( e ); }
                                                              }
                              ;
                                

exceptionVisibility
returns [String visibility]
                              : PRIVATE                     { $visibility = $PRIVATE.text; }
                              | PUBLIC                      { $visibility = $PUBLIC.text; }
                              ;

//---------------------------------------------------------
// Type Definition
//---------------------------------------------------------

typeForwardDeclaration
returns [Object type]
                              : ^( TYPE_DECLARATION
                                   typeName                 
                                   typeVisibility
                                                              {
                                                                  args[0] = $typeName.name;
                                                                  args[1] = $typeVisibility.visibility;
                                                                  populate( "type", args );
                                                                  try {
                                                                    $type = loader.create( "TypeDeclaration" );
                                                                    loader.set_attribute( $type, "name", $typeName.name );
                                                                    loader.set_attribute( $type, "visibility", "Visibility::" + $typeVisibility.visibility );
                                                                  } catch ( XtumlException e ) { System.err.println( e ); }
                                                              }
                                   pragmaList["declaration"]				
                                 )                          
                                                              {
                                                                  populate( "type", args ); // end type
                                                              }
                              ;
                              

typeDeclaration
returns [Object type]
                              : ^( TYPE
                                   typeName                 
                                   typeVisibility
                                                              {
                                                                  args[0] = $typeName.name;
                                                                  args[1] = $typeVisibility.visibility;
                                                                  args[2] = $TYPE.text;
                                                                  populate( "type", args );
                                                                  try {
                                                                    $type = loader.select( "TypeDeclaration", $typeName.name );
                                                                    if ( $type == null ) {
                                                                      $type = loader.create( "TypeDeclaration" );
                                                                    }
                                                                    loader.set_attribute( $type, "name", $typeName.name );
                                                                    loader.set_attribute( $type, "visibility", "Visibility::" + $typeVisibility.visibility );
                                                                  } catch ( XtumlException e ) { System.err.println( e ); }
                                                              }
                                   description
                                   pragmaList[""]				
                                   typeDefinition			
                                                              {
                                                                try {
                                                                  loader.relate( $typeDefinition.type, $type, 6234, "" );
                                                                } catch ( XtumlException e ) { System.err.println( e ); }
                                                              }
                                 )                          
                                                              {
                                                                  populate( "type", args ); // end type
                                                              }
                              ;
                              

typeDefinition
returns [Object type]
@init
{
  try {
    $type = loader.create( "TypeDefinition" );
  } catch ( XtumlException e ) { System.err.println( e ); }
}
                              : structureTypeDefinition     
                                                            {
                                                              try {
                                                                Object fulltype = loader.create( "FullTypeDefinition" );
                                                                loader.relate( fulltype, $type, 6234, "" );
                                                                loader.relate( $structureTypeDefinition.type, fulltype, 6219, "" );
                                                              } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                              | enumerationTypeDefinition   
                                                            {
                                                              try {
                                                                Object fulltype = loader.create( "FullTypeDefinition" );
                                                                loader.relate( fulltype, $type, 6234, "" );
                                                                loader.relate( $enumerationTypeDefinition.type, fulltype, 6219, "" );
                                                              } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                              | constrainedTypeDefinition   
                                                            {
                                                              try {
                                                                Object fulltype = loader.create( "FullTypeDefinition" );
                                                                loader.relate( fulltype, $type, 6234, "" );
                                                                loader.relate( $constrainedTypeDefinition.type, fulltype, 6219, "" );
                                                              } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                              | typeReference               
                                                            {
                                                              // CDS - I think here we will have a UserDefinedType.
                                                            }
                              | unconstrainedArrayDefinition
                                                            {
                                                              try {
                                                                Object fulltype = loader.create( "FullTypeDefinition" );
                                                                loader.relate( fulltype, $type, 6234, "" );
                                                                loader.relate( $unconstrainedArrayDefinition.type, fulltype, 6219, "" );
                                                              } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                              ;

typeVisibility
returns [String visibility]
                              : PRIVATE                     { $visibility = $PRIVATE.text; }
                              | PUBLIC                      { $visibility = $PUBLIC.text; }
                              ;



// Constrained Type
constrainedTypeDefinition
returns [Object type]
                              : ^( CONSTRAINED_TYPE
                                   typeReference
                                   typeConstraint
                                 )                          
                              ;

typeConstraint
returns [Object constraint]
                              : rangeConstraint             
                              | deltaConstraint             
                              | digitsConstraint            
                              ;

rangeConstraint
returns [Object range]
                              : ^( RANGE
                                   expression
                                 )                          
                              ;

deltaConstraint
returns [Object delta]
                              : ^( DELTA
                                   expression
                                   rangeConstraint
                                 )                          
                              ;

digitsConstraint
returns [Object digits]
                              : ^( DIGITS
                                   expression
                                   rangeConstraint
                                 )                          
                              ;

// Structure Type
structureTypeDefinition
returns [Object type]
                              : ^( STRUCTURE
                                   ( structureComponentDefinition 
                                                            
                                   )+
                                 )                          
                              ;


structureComponentDefinition
//returns [StructureElement element]
                              : ^( COMPONENT_DEFINITION
                                   componentName
                                   typeReference
                                   expression?
                                   pragmaList["omit"]
                                 )                          
                              ;

componentName
returns [String name]
                              : ^( COMPONENT_NAME
                                   identifier
                                 )                          
                              ;


// Enumeration Type
enumerationTypeDefinition
returns [Object type]

                              : ^( ENUM
                                   ( enumerator             
                                   )+
                                 )                          
                              ;

enumerator
returns [Object item]
                              : ^( ENUMERATOR
                                   enumeratorName
                                   expression?
                                 )                          
                              ;

enumeratorName
returns [String name]         : ^( ENUMERATOR_NAME
                                   identifier
                                 )                          
                              ;


// Unconstrained array
unconstrainedArrayDefinition
returns [Object type]
                              : ^( UNCONSTRAINED_ARRAY
                                   index=typeReference
                                   contained=typeReference
                                 )                          
                              ;

//---------------------------------------------------------
// Type Reference
//---------------------------------------------------------

typeReference
returns [String type]
                              : namedTypeRef                { $type = $namedTypeRef.type[2]; }
                              | constrainedArrayTypeRef     { $type = "levi"; }//$constrainedArrayTypeRef.type }
                              | instanceTypeRef             { $type = "levi"; }//$instanceTypeRef.type }
                              | sequenceTypeRef             { $type = "levi"; }//$sequenceTypeRef.type }
                              | arrayTypeRef                { $type = "levi"; }//$arrayTypeRef.type }
                              | setTypeRef                  { $type = "levi"; }//$setTypeRef.type }
                              | bagTypeRef                  { $type = "levi"; }//$bagTypeRef.type }
                              | dictionaryTypeRef           { $type = "levi"; }//$dictionaryTypeRef.type }
                              ;

instanceTypeRef
//returns [InstanceType type]
                              : ^( INSTANCE
                                   objectReference
                                   ANONYMOUS?
                                 )                          
                              ;

namedTypeRef
returns [String[\] type]
//returns [BasicType type]
@init
{
    String[] t = new String[3];
    for ( int i = 0; i < t.length; i++ ) t[i] = "";
}
                              : ^( NAMED_TYPE
                                   optionalDomainReference
                                   typeName
                                   ANONYMOUS?
                                 )                          
                                                            { 
                                                                t[0] = $ANONYMOUS.text;
                                                                t[1] = $optionalDomainReference.ref;
                                                                t[2] = $typeName.name;
                                                                $type = t;
                                                            }
                              ;

userDefinedTypeRef
//returns [UserDefinedType type]
                              : ^( NAMED_TYPE
                                   optionalDomainReference
                                   typeName
                                 )                          
                              ;

constrainedArrayTypeRef
//returns [UnconstrainedArraySubtype type]
                              : ^( CONSTRAINED_ARRAY
                                   userDefinedTypeRef
                                   arrayBounds
                                 )                          
                              ;


sequenceTypeRef
//returns [SequenceType type]
                              : ^( SEQUENCE
                                   typeReference
                                   expression?
                                   ANONYMOUS?
                                 )                          
                              ;

arrayTypeRef
//returns [ArrayType type]
                              : ^( ARRAY
                                   typeReference
                                   arrayBounds
                                   ANONYMOUS?
                                 )                          
                              ;

setTypeRef
//returns [SetType type]
                              : ^( SET
                                   typeReference
                                   ANONYMOUS?
                                 )                          
                              ;

bagTypeRef
//returns [BagType type]
                              : ^( BAG
                                   typeReference
                                   ANONYMOUS?
                                 )                          
                              ;

dictionaryTypeRef
//returns [DictionaryType type]
                              : ^( DICTIONARY
                                   (^(KEY   key=typeReference))?
                                   (^(VALUE value=typeReference))?
                                   ANONYMOUS?
                                 )                          
                              ;
typeName
returns [String name]
                              : ^( TYPE_NAME
                                   identifier )             { $name = $identifier.name; }
                              ;

arrayBounds
//returns [Expression exp]
                              : ^( ARRAY_BOUNDS
                                   expression )             
                              ;

//---------------------------------------------------------
// Terminator Definition
//---------------------------------------------------------

terminatorName
returns [String name]
                              : ^( TERMINATOR_NAME
                                   identifier )             { $name = $identifier.name; }
                              ;


domainTerminatorDefinition
returns [Object terminator]
                              : ^( TERMINATOR_DEFINITION
                                   terminatorName             
                                                              {
                                                                  args[0] = $terminatorName.name;
                                                                  populate( "terminator", args );
                                                                  try {
                                                                    $terminator = loader.create( "DomainTerminator" );
                                                                    loader.set_attribute( $terminator, "name", $terminatorName.name );
                                                                  } catch ( XtumlException e ) { System.err.println( e ); }
                                                              }
                                   description
                                   pragmaList[""]                 
                                   ( terminatorServiceDeclaration//[terminator] 
                                                              {
                                                                try {
                                                                  loader.relate( $terminatorServiceDeclaration.terminatorservice, $terminator, 5306, "" );
                                                                } catch ( XtumlException e ) { System.err.println( e ); }
                                                              }
                                   )*
                                 )
                                                              {
                                                                populate( "terminator", args );  // end terminator
                                                              }
                              ;

projectTerminatorDefinition
returns [Object terminator]
                              : ^( TERMINATOR_DEFINITION
                                   terminatorName
                                                              {
                                                                  args[0] = $terminatorName.name;
                                                                  populate( "terminator", args );
                                                                  try {
                                                                    $terminator = loader.create( "ProjectTerminator" );
                                                                    loader.set_attribute( $terminator, "name", $terminatorName.name );
                                                                  } catch ( XtumlException e ) { System.err.println( e ); }
                                                              }
                                   description
                                   pragmaList[""]                 
                                   ( projectTerminatorServiceDeclaration
                                                              {
                                                                try {
                                                                  loader.relate( $projectTerminatorServiceDeclaration.terminatorservice, $terminator, 5903, "" );
                                                                } catch ( XtumlException e ) { System.err.println( e ); }
                                                              }
                                   )*
                                 )
                                                              {
                                                                populate( "terminator", args );  // end terminator
                                                              }
                              ;



terminatorServiceDeclaration//[DomainTerminator terminator]
returns [Object terminatorservice]
@init { Object service = null; }
                              : ^( TERMINATOR_SERVICE_DECLARATION
                                   serviceVisibility
                                   serviceName
                                                            {
                                                                  args[2] = $serviceVisibility.visibility;
                                                                  args[3] = $serviceName.name;
                                                                  populate( "routine", args );
                                                                  try {
                                                                    service = loader.create( "Service" );
                                                                    loader.set_attribute( service, "name", $serviceName.name );
                                                                    loader.set_attribute( service, "visibility", "Visibility::" + $serviceVisibility.visibility );
                                                                    $terminatorservice = loader.create( "DomainTerminatorService" );
                                                                    loader.relate( $terminatorservice, service, 5203, "" );
                                                                  } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   description
                                   parameterList
                                                            {
                                                              if ( null != $parameterList.firstparameter ) {
                                                                try {
                                                                  loader.relate( $parameterList.firstparameter, service, 5204, "" );
                                                                } catch ( XtumlException e ) { System.err.println( e ); }
                                                              }
                                                            }
                                   returnType?
                                   pragmaList[""]
                                 )
                                                            {
                                                                  populate( "routine", args );      // end operation
                                                            }
                                                            
                              ;

projectTerminatorServiceDeclaration//[ProjectTerminator terminator]
returns [Object terminatorservice]
@init { Object service = null; }
                              : ^( TERMINATOR_SERVICE_DECLARATION
                                   serviceVisibility
                                   serviceName              
                                                            {
                                                                  args[2] = $serviceVisibility.visibility;
                                                                  args[3] = $serviceName.name;
                                                                  populate( "routine", args );
                                                                  try {
                                                                    service = loader.create( "Service" );
                                                                    loader.set_attribute( service, "name", $serviceName.name );
                                                                    loader.set_attribute( service, "visibility", "Visibility::" + $serviceVisibility.visibility );
                                                                    $terminatorservice = loader.create( "ProjectTerminatorService" );
                                                                    loader.relate( $terminatorservice, service, 5203, "" );
                                                                  } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   description
                                   parameterList
                                                            {
                                                              if ( null != $parameterList.firstparameter ) {
                                                                try {
                                                                  loader.relate( $parameterList.firstparameter, service, 5204, "" );
                                                                } catch ( XtumlException e ) { System.err.println( e ); }
                                                              }
                                                            }
                                   (returnType)?
                                   pragmaList[""]
                                 )
                                                            {
                                                                  populate( "routine", args );      // end operation
                                                            }
                                                            
                              ;


//---------------------------------------------------------
// Object Definition
//---------------------------------------------------------

objectName
returns [String name]
                              : ^( OBJECT_NAME
                                   identifier )             { $name = $identifier.name; }
                              ;


objectReference
returns [String[\] ref]
//returns [ObjectNameExpression ref]
@init
{
    String[] r = new String[2];
    for ( int i = 0; i < r.length; i++ ) r[i] = "";
}
                              : optionalDomainReference
                                objectName                  
                                                            { 
                                                                r[0] = $optionalDomainReference.ref;
                                                                r[1] = $objectName.name;
                                                                $ref = r;
                                                            }
                              ;

fullObjectReference
returns [String[\] ref]
//returns [ObjectNameExpression ref]
@init
{
    String[] r = new String[2];
    for ( int i = 0; i < r.length; i++ ) r[i] = "";
}
                              : domainReference
                                objectName                  
                                                            { 
                                                                r[0] = $domainReference.ref;
                                                                r[1] = $objectName.name;
                                                                $ref = r;
                                                            }
                              ;


optionalObjectReference
returns [String[\] ref]
//returns [ObjectNameExpression ref]
                              : objectReference             { $ref = $objectReference.ref; }
                              | /* blank */                 { 
                                                                String[] r = new String[2];
                                                                for ( int i = 0; i < r.length; i++ ) r[i] = "";
                                                                $ref = r;
                                                            }
                              ;
attributeName
returns [String name]
                              : ^( ATTRIBUTE_NAME
                                   identifier )             { $name = $identifier.name; }
                              ;

objectDeclaration
returns [Object object]
                              : ^( OBJECT_DECLARATION
                                   objectName
                                                            {
                                                                args[0] = $objectName.name;
                                                                populate( "object", args );
                                                                try {
                                                                  $object = loader.create( "ObjectDeclaration" );
                                                                  loader.set_attribute( $object, "name", $objectName.name );
                                                                } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   pragmaList["declaration"]
                                 )                          
                                                            {
                                                                populate( "object", args ); // end object
                                                            }
                                 
                              ;


objectDefinition
returns [Object object]
                                                                                             
                              : ^( OBJECT_DEFINITION
                                   objectName               
                                                            {
                                                                args[0] = $objectName.name;
                                                                populate( "object", args );
                                                                try {
                                                                  $object = loader.select( "ObjectDeclaration", $objectName.name );
                                                                  if ( $object == null ) {
                                                                    $object = loader.create( "ObjectDeclaration" );
                                                                  }
                                                                  loader.set_attribute( $object, "name", $objectName.name );
                                                                } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   ( attributeDefinition      
                                                            {
                                                                try {
                                                                  loader.relate( $attributeDefinition.attribute, $object, 5802, "" );
                                                                } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   | identifierDefinition     
                                   | objectServiceDeclaration 
                                   | eventDefinition          
                                   | stateDeclaration         
                                   | transitionTable          
                                   )*
                                   description
                                   pragmaList[""]                 
                                 )
                                                            {
                                                                populate( "object", args ); // end object
                                                            }
                              ;

attributeDefinition
returns [Object attribute]
                              : ^( ATTRIBUTE_DEFINITION
                                   attributeName            
                                   PREFERRED? UNIQUE?
                                                            {
                                                                args[0] = $attributeName.name;
                                                                if ( $PREFERRED != null )
                                                                    args[1] = $PREFERRED.text;
                                                                else args[1] = "";
                                                                if ( $UNIQUE != null )
                                                                    args[2] = $UNIQUE.text;
                                                                else args[2] = "";
                                                                populate( "attribute", args );
                                                                try {
                                                                  $attribute = loader.create( "AttributeDeclaration" );
                                                                  loader.set_attribute( $attribute, "name", $attributeName.name );
                                                                  if ( $PREFERRED != null ) {
                                                                    loader.set_attribute( $attribute, "preferred", false );
                                                                  } else {
                                                                    loader.set_attribute( $attribute, "preferred", true );
                                                                  }
                                                                  if ( $UNIQUE == null ) {
                                                                    loader.set_attribute( $attribute, "unique", false );
                                                                  } else {
                                                                    loader.set_attribute( $attribute, "unique", true );
                                                                  }
                                                                } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   ( attReferential         
                                   )*
                                   description
                                   typeReference
                                                            {
                                                                args[0] = $typeReference.type;
                                                                populate( "typeref", args );
                                                                try {
                                                                  Object t = loader.select( "TypeDeclaration", $typeReference.type );
                                                                  loader.relate( $attribute, t, 5803, "" );
                                                                } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   (expression
                                                            {
                                                                args[0] = $ATTRIBUTE_DEFINITION.text;
                                                                populate( "expression", args );
                                                            }
                                   )?
                                   pragmaList[""]
                                 )                          
                                                            {
                                                                populate( "attribute", args );  // end attribute
                                                            }

                              ;

attReferential
//returns [ReferentialAttributeDefinition ref]
                              : ^( REFERENTIAL
                                   relationshipSpec//[new ObjectNameExpression(null,currentObject),false,false]
                                   attributeName
                                 )                          
                                                            {
                                                                args[0] = $relationshipSpec.spec[1];
                                                                args[1] = $relationshipSpec.spec[0];
                                                                args[2] = $relationshipSpec.spec[2];
                                                                args[3] = $relationshipSpec.spec[4];
                                                                args[4] = $attributeName.name;
                                                                populate( "referential", args );
                                                            }
                              ;


relationshipSpec//[Expression lhs, boolean allowToAssoc, boolean forceToAssoc]
returns [String[\] spec]
//returns [RelationshipSpecification.Reference rel]
@init
{
    String[] s = new String[5];
    for ( int i = 0; i < s.length; i++ ) s[i] = "";
}
                              : ^( RELATIONSHIP_SPEC
                                   relationshipReference    
                                                            {
                                                                s[0] = $relationshipReference.ref[0];
                                                                s[1] = $relationshipReference.ref[1];
                                                            }
                                   ( objOrRole
                                                            {
                                                                s[2] = $objOrRole.name;
                                                            }
                                   ( objectReference
                                                            {
                                                                s[3] = $objectReference.ref[0];
                                                                s[4] = $objectReference.ref[1];
                                                            }
                                   )? 
                                   )?
                                 ) 													
                                                            {
                                                                $spec = s;
                                                            }
                              ;

objOrRole
returns [String name]
                              : identifier                  { $name = $identifier.name; }
                              ;


objectServiceDeclaration
returns [Object objectservice]
@init { Object service = null; }
                              : ^( OBJECT_SERVICE_DECLARATION
                                   serviceVisibility
                                   ( INSTANCE
                                     relationshipReference?)?
                                   serviceName
                                                            {
                                                                  args[2] = $serviceVisibility.visibility;
                                                                  args[3] = $serviceName.name;
                                                                  if ( $INSTANCE != null )
                                                                      args[4] = $INSTANCE.text;
                                                                  if ( $relationshipReference.ref != null )
                                                                      args[5] = $relationshipReference.ref[1];
                                                                  populate( "operation", args );
                                                                  try {
                                                                    service = loader.create( "Service" );
                                                                    loader.set_attribute( service, "name", $serviceName.name );
                                                                    loader.set_attribute( service, "visibility", "Visibility::" + $serviceVisibility.visibility );
                                                                    $objectservice = loader.create( "ObjectService" );
                                                                    loader.relate( $objectservice, service, 5203, "" );
                                                                  } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   description
                                   parameterList
                                                            {
                                                              if ( null != $parameterList.firstparameter ) {
                                                                try {
                                                                  loader.relate( $parameterList.firstparameter, service, 5204, "" );
                                                                } catch ( XtumlException e ) { System.err.println( e ); }
                                                              }
                                                            }
                                   returnType?
                                   pragmaList[""]
                                 )                          
                                                            {
                                                                  populate( "operation", args );      // end operation
                                                            }
                              ;


identifierDefinition

                              : ^( IDENTIFIER
                                                            {
                                                                args[0] = "symbolic";           // symbolic argument
                                                                populate( "identifier", args );
                                                            }
                                   ( attributeName          
                                                            {
                                                                args[0] = $attributeName.name;
                                                                populate( "attribute", args );
                                                                populate( "attribute", args );  // end attribute
                                                            }
                                   )+
                                   pragmaList[""]
                                 )                     
                                                            {
                                                                populate( "identifier", args );  // end identifier
                                                            }
                              ;

eventDefinition
                              : ^( EVENT         
                                   eventName                
                                   eventType                
                                                            {
                                                                args[0] = $eventName.name;
                                                                args[1] = $eventType.type;
                                                                populate( "event", args );
                                                            }
                                   description
                                   parameterList
                                   pragmaList[""]               
                                 )
                                                            {
                                                                populate( "event", args );  // end event
                                                            }
                                                            
                              ;

eventName
returns [String name]
                              : ^( EVENT_NAME
                                   identifier )             { $name = $identifier.name; }
                              ;

eventType
returns [String type]
//returns [EventType type]
                              : ASSIGNER                    { $type = $ASSIGNER.text; }
                              | CREATION                    { $type = $CREATION.text; }
                              | NORMAL                      { $type = ""; }
                              ;

stateDeclaration
                              : ^( STATE
                                   stateName                
                                   stateType               
                                                            {
                                                                args[2] = $stateName.name;
                                                                args[3] = $stateType.type;
                                                                populate( "state", args );
                                                            }
                                   description
                                   parameterList
                                   pragmaList[""]              
                                )                           
                                                            {
                                                                populate( "state", args );  // end state
                                                            }
                              ;

stateName
returns [String name]
                              : ^( STATE_NAME
                                   identifier )             { $name = $identifier.name; }
                              ;

stateType
returns [String type]
//returns [StateType type]
                              : ASSIGNER                    { $type = $ASSIGNER.text; }
                              | START                       { $type = $START.text; }
                              | CREATION                    { $type = $CREATION.text; }
                              | TERMINAL                    { $type = $TERMINAL.text; }
                              | NORMAL                      { $type = ""; }
                              ;


transitionTable

                              : ^( TRANSITION_TABLE
                                   transTableType
                                                            {
                                                                args[0] = $transTableType.type;
                                                                args[1] = "symbolic";
                                                                populate( "transitiontable", args );
                                                            }
                                   ( transitionRow          
                                   )+
                                   pragmaList[""]
                                 )                          
                                                            {
                                                                populate( "transitiontable", args );   // end transitiontable
                                                            }
                              ;


transTableType
returns [String type]
//returns [boolean isAssigner]
                              : ASSIGNER                    { $type = $ASSIGNER.text; }
                              | NORMAL                      { $type = ""; }
                              ;

transitionRow
//returns [TransitionRow row]

                              : ^( TRANSITION_ROW
                                   startState
                                   ( transitionOption[$startState.name]
                                   )+
                                   pragmaList[$startState.name]
                                )                           
                              ;

transitionOption[String startState]
//returns [TransitionOption option]
                              : ^( TRANSITION_OPTION
                                   incomingEvent
                                   endState
                                 )                          
                                                            {
                                                                args[0] = startState;
                                                                args[1] = $incomingEvent.ref[0];
                                                                args[2] = $incomingEvent.ref[1];
                                                                args[3] = $incomingEvent.ref[2];
                                                                args[4] = $endState.name;
                                                                populate( "transition", args );
                                                            }
                              ;

incomingEvent
returns [String[\] ref]
//returns [EventExpression ref]
                              : ^( EVENT
                                   eventReference           { $ref = $eventReference.ref; }
                                 )
                              ;

startState
returns [String name]
                              : NON_EXISTENT                { $name = $NON_EXISTENT.text; }
                              | stateName                   { $name = $stateName.name; }
                              ;

endState
returns [String name]
//returns [String name, TransitionType type]
                              : stateName                   { $name = $stateName.name; }
                              | IGNORE                      { $name = $IGNORE.text; }
                              | CANNOT_HAPPEN               { $name = $CANNOT_HAPPEN.text; }
                              ;

eventReference
returns [String[\] ref]
//returns [EventExpression ref]
@init
{
    String[] r = new String[3];
    for ( int i = 0; i < r.length; i++ ) r[i] = "";
}
                              : optionalObjectReference
                                eventName                   
                                                            { 
                                                                r[0] = $optionalObjectReference.ref[0];
                                                                r[1] = $optionalObjectReference.ref[1];
                                                                r[2] = $eventName.name;
                                                                $ref = r;
                                                            }
                              ;


//---------------------------------------------------------
// Service Declaration
//---------------------------------------------------------

domainServiceDeclaration
returns [Object domainservice]
                              : ^( DOMAIN_SERVICE_DECLARATION
                                   serviceVisibility
                                   serviceName
                                                            {
                                                                  args[2] = $serviceVisibility.visibility;
                                                                  args[3] = $serviceName.name;
                                                                  populate( "routine", args );
                                                            }
                                   description
                                   parameterList
                                   returnType?
                                   pragmaList[""]
                                 )
                                                            {
                                                                  populate( "routine", args );      // end operation
                                                            }
                                                            
                              ;


parameterDefinition
returns [Object parameter]
                              : ^( PARAMETER_DEFINITION
                                   parameterName
                                   parameterMode
                                                            {
                                                                  args[0] = $parameterName.name;
                                                                  args[1] = $parameterMode.mode;
                                                                  populate( "parameter", args );
                                                                  try {
                                                                    $parameter = loader.create( "ParameterDefinition" );
                                                                    loader.set_attribute( $parameter, "name", $parameterName.name );
                                                                    loader.set_attribute( $parameter, "mode", "ParameterMode::" + $parameterMode.mode );
                                                                  } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   parameterType)           
                              ;
                              
parameterList
returns [Object firstparameter]
@init
{
  Object previousparameter = null;
}

                              : ( parameterDefinition       { 
                                                              if ( null == previousparameter ) {
                                                                firstparameter = $parameterDefinition.parameter;
                                                              } else {
                                                                try {
                                                                  loader.relate( $parameterDefinition.parameter, previousparameter, 5208, "succeeds" );
                                                                } catch ( XtumlException e ) { System.err.println( e ); }
                                                              }
                                                              previousparameter = $parameterDefinition.parameter;
                                                            }
                               )*
                              ;


serviceVisibility
returns [String visibility]
                              : PRIVATE                     { $visibility = $PRIVATE.text; }
                              | PUBLIC                      { $visibility = $PUBLIC.text; }
                              ;

parameterMode
returns [String mode]
                              : IN                          { $mode = $IN.text; }
                              | OUT                         { $mode = $OUT.text; }
                              ;


serviceName
returns [String name]
                              : ^( SERVICE_NAME
                                   identifier )             { $name = $identifier.name; }
                              ;

parameterName
returns [String name]
                              : ^( PARAMETER_NAME
                                   identifier )             { $name = $identifier.name; }
                              ;

parameterType
returns [String type]
//returns [BasicType type]
                              : ^( PARAMETER_TYPE
                                   typeReference )
                                                              {
                                                                  args[0] = $typeReference.type;
                                                                  populate( "typeref", args );
                                                              }
                              ;

returnType
//returns [BasicType type]
                              : ^( RETURN_TYPE
                                   typeReference )
                                                              {
                                                                  args[0] = $typeReference.type;
                                                                  populate( "typeref", args );
                                                              }
                              ;


//---------------------------------------------------------
// Relationship Definition
//---------------------------------------------------------


relationshipDefinition
returns [Object relationship]
                              : regularRelationshipDefinition
                              | assocRelationshipDefinition   
                              | subtypeRelationshipDefinition 
                              ;



regularRelationshipDefinition
                              : ^( REGULAR_RELATIONSHIP_DEFINITION
                                   relationshipName
                                                            {
                                                                args[0] = $relationshipName.name;
                                                                populate( "regularrel", args );
                                                            }
                                   description
                                   leftToRight=halfRelationshipDefinition
                                   rightToLeft=halfRelationshipDefinition
                                                            {
                                                                populate( "participation", args );  // end participation
                                                            }
                                   pragmaList[""]
                                 )                          
                                                            {
                                                                populate( "regularrel", args );   // end regularrel
                                                            }
                              ;


assocRelationshipDefinition
                              : ^( ASSOCIATIVE_RELATIONSHIP_DEFINITION
                                   relationshipName
                                                            {
                                                                args[0] = $relationshipName.name;
                                                                populate( "associative", args );
                                                            }
                                   description
                                   leftToRight=halfRelationshipDefinition
                                   rightToLeft=halfRelationshipDefinition
                                   assocObj=objectReference
                                                            {
                                                                populate( "participation", args );  // end participation

                                                                // update with the associative object
                                                                args[0] = $relationshipName.name;
                                                                args[1] = $assocObj.ref[0];
                                                                args[2] = $assocObj.ref[1];
                                                                populate( "associative", args );
                                                            }
                                   pragmaList[""]
                                 )                          
                                                            {
                                                                populate( "associative", args );   // end associativerelationship
                                                            }

                              ;

halfRelationshipDefinition
//returns [HalfRelationship half]
                              : ^( HALF_RELATIONSHIP
                                   from=objectReference
                                   conditionality
                                   rolePhrase
                                   multiplicity
                                   to=objectReference
                                 )                          
                                                            { 
                                                                // populate a side of participation
                                                                args[0] = $from.ref[0];
                                                                args[1] = $from.ref[1];
                                                                args[2] = $rolePhrase.role;
                                                                args[3] = $conditionality.cond;
                                                                args[4] = $multiplicity.mult;
                                                                args[5] = $to.ref[0];
                                                                args[6] = $to.ref[1];
                                                                populate( "participation", args );
                                                            }
                              ;


subtypeRelationshipDefinition
//returns [SubtypeRelationshipDeclaration relationship]

                              : ^( SUBTYPE_RELATIONSHIP_DEFINITION
                                   relationshipName
                                                            {
                                                                args[0] = $relationshipName.name;
                                                                populate( "subsuper", args );
                                                            }
                                   description
                                   supertype=objectReference
                                                            {
                                                                args[0] = $supertype.ref[0];
                                                                args[1] = $supertype.ref[1];
                                                                populate( "participation", args );
                                                            }
                                   (subtype=objectReference   
                                                            {
                                                                args[0] = $subtype.ref[0];
                                                                args[1] = $subtype.ref[1];
                                                                args[5] = $supertype.ref[0];
                                                                args[6] = $supertype.ref[1];
                                                                populate( "participation", args );
                                                            }
                                   )+
                                                            {
                                                                populate( "participation", args );  // end participation
                                                            }
                                   pragmaList[""]
                                 )                          
                                                            {
                                                                populate( "subsuper", args );   // end subsuper
                                                            }

                              ;

rolePhrase
returns [String role]
                              : ^( ROLE_PHRASE
                                   identifier )             { $role = $identifier.name; }
                              ;

conditionality
returns [String cond]
//returns [boolean cond]
                              : UNCONDITIONALLY             { $cond = $UNCONDITIONALLY.text; }
                              | CONDITIONALLY               { $cond = $CONDITIONALLY.text; }
                              ;

multiplicity
returns [String mult]
//returns [MultiplicityType mult]
                              : ONE                         { $mult = $ONE.text; }
                              | MANY                        { $mult = $MANY.text; }
                              ;


relationshipName
returns [String name]
                              : ^( RELATIONSHIP_NAME
                                   RelationshipName  
                                 )                          { $name = $RelationshipName.text; }
                              ;
                              

relationshipReference
returns [String[\] ref]
//returns [RelationshipDeclaration.Reference ref]
                              : optionalDomainReference
                                relationshipName            
                                                            { 
                                                                String[] r = new String[2];
                                                                r[0] = $optionalDomainReference.ref;
                                                                r[1] =$relationshipName.name;
                                                                $ref = r;
                                                            }
                              ;


//---------------------------------------------------------
// Pragma Definition
//---------------------------------------------------------


pragmaList[String list]
//returns [ PragmaList pragmas ]

                              : ( pragma[list]                    
                                )*                          
                              ;

pragma[String list]
//returns [PragmaDefinition def]

                              : ^( PRAGMA
                                   pragmaName               
                                                            {
                                                                if ( !list.equals("omit") ) {
                                                                    args[0] = $pragmaName.name;
                                                                    args[1] = list;
                                                                    populate( "pragma", args );
                                                                }
                                                            }
                                   ( pragmaValue            
                                                            {
                                                                if ( !list.equals("omit") ) {
                                                                    args[0] = $pragmaValue.value;
                                                                    populate( "pragmaitem", args );
                                                                }
                                                            } 
                                   )*
                                 )                          
                                                            {
                                                                if ( !list.equals("omit") ) populate( "pragma", args ); // end pragma
                                                            }
                              ;

pragmaValue
returns [ String value ]
                              : identifier                  { $value = $identifier.name; }
                              | literalExpression           { $value = $literalExpression.exp; }
                              ;

pragmaName
returns [ String name ]
                              : ^( PRAGMA_NAME
                                   identifier               { $name = $identifier.name; }
                                 )
                              ;

//---------------------------------------------------------
// Descriptions
//---------------------------------------------------------

description
returns [String text]
                              : ^( DESCRIPTION              {   StringBuilder descrip = new StringBuilder(); }
                                   (Description             {   descrip.append( $Description.text.substring(3) ); }
                                   )*
                                                            {
                                                                args[0] = descrip.toString();
                                                                populate( "description", args );
                                                                $text = descrip.toString();
                                                            }
                                 )
                              ;

//---------------------------------------------------------
// Dynamic Behaviour
//---------------------------------------------------------

/*  This rule has been added to allow to parse any activity action body file
    without knowledge of what type of activity it contained - LPS */

activityDefinition            : domainServiceDefinition
                              | terminatorServiceDefinition
                              | objectServiceDefinition
                              | stateDefinition
                              ;


domainServiceDefinition//[DomainService service]
returns [Object domainservice]
@init
{ Object service = null; }
//scope NameScope;

                              : ^( DOMAIN_SERVICE_DEFINITION
                                   serviceVisibility
                                   domainReference
                                   serviceName
                                                            {
                                                                  args[0] = $domainReference.ref;
                                                                  args[2] = $serviceVisibility.visibility;
                                                                  args[3] = $serviceName.name;
                                                                  populate( "routine", args );
                                                                  try {
                                                                    service = loader.create( "Service" );
                                                                    loader.set_attribute( service, "name", $serviceName.name );
                                                                    loader.set_attribute( service, "visibility", "Visibility::" + $serviceVisibility.visibility );
                                                                    $domainservice = loader.create( "DomainService" );
                                                                    loader.relate( $domainservice, service, 5203, "" );
                                                                  } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   parameterList
                                                            {
                                                                try {
                                                                  loader.relate( $parameterList.firstparameter, service, 5204, "" );
                                                                } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                                   returnType?
                                   codeBlock
                                                            {
                                                                args[0] = $DOMAIN_SERVICE_DEFINITION.text + " service;";
                                                                populate( "codeblock", args );
                                                            }
                                   pragmaList[""]                  
                                 )                                                   
                                                            {
                                                                populate( "routine", args );      // end operation
                                                            }
                                                            
                              ;


terminatorServiceDefinition//[DomainTerminatorService service]
//scope NameScope;


                              : ^( TERMINATOR_SERVICE_DEFINITION
                                   serviceVisibility
                                   domainReference
                                   terminatorName
                                   serviceName
                                                            {
                                                                  args[0] = $domainReference.ref;
                                                                  args[1] = $terminatorName.name;
                                                                  args[2] = $serviceVisibility.visibility;
                                                                  args[3] = $serviceName.name;
                                                                  populate( "routine", args );
                                                            }
                                   parameterList
                                                            {
                                                                args[0] = $TERMINATOR_SERVICE_DEFINITION.text + " service;";
                                                                populate( "codeblock", args );
                                                            }
                                   returnType?
                                   codeBlock
                                   pragmaList[""]                  
                                 )                                                   
                                                            {
                                                                populate( "routine", args );      // end operation
                                                            }
                                                            
                              ;


projectTerminatorServiceDefinition//[ProjectTerminatorService service]
//scope NameScope;
                              : ^( TERMINATOR_SERVICE_DEFINITION
                                   serviceVisibility
                                   domainReference
                                   terminatorName
                                   serviceName
                                                            {
                                                                  args[0] = $domainReference.ref;
                                                                  args[1] = $terminatorName.name;
                                                                  args[2] = $serviceVisibility.visibility;
                                                                  args[3] = $serviceName.name;
                                                                  populate( "routine", args );
                                                            }
                                   parameterList
                                   returnType?
                                   codeBlock         
                                                            {
                                                                args[0] = $TERMINATOR_SERVICE_DEFINITION.text + " service;";
                                                                populate( "codeblock", args );
                                                            }
                                   pragmaList[""]                  
                                 )                                                   
                                                            {
                                                                populate( "routine", args );      // end operation
                                                            }
                                                            
                              ;



objectServiceDefinition//[ObjectService service]
//scope NameScope;


                              :^( OBJECT_SERVICE_DEFINITION
                                   serviceVisibility
                                   INSTANCE?
                                   fullObjectReference
                                   serviceName
                                                            {
                                                                  args[0] = $fullObjectReference.ref[0];
                                                                  args[1] = $fullObjectReference.ref[1];
                                                                  args[2] = $serviceVisibility.visibility;
                                                                  args[3] = $serviceName.name;
                                                                  if ( $INSTANCE != null )
                                                                      args[4] = $INSTANCE.text;
                                                                  populate( "operation", args );
                                                            }
                                   parameterList
                                   returnType?
                                   codeBlock
                                                            {
                                                                args[0] = $OBJECT_SERVICE_DEFINITION.text + " service;";
                                                                populate( "codeblock", args );
                                                            }
                                   pragmaList[""]                           
                                 )                          
                                                            {
                                                                populate( "operation", args );      // end operation
                                                            }
                              ;


stateDefinition//[State stateDef]
//scope NameScope;


                              : ^( STATE_DEFINITION
                                   stateType
                                   fullObjectReference
                                   stateName
                                                            {
                                                                args[0] = $fullObjectReference.ref[0];
                                                                args[1] = $fullObjectReference.ref[1];
                                                                args[2] = $stateName.name;
                                                                args[3] = $stateType.type;
                                                                populate( "state", args );
                                                            }
                                   parameterList
                                   codeBlock
                                                            {
                                                                args[0] = $STATE_DEFINITION.text + " state;";
                                                                populate( "codeblock", args );
                                                            }
                                   pragmaList[""]                
                                 )                          
                                                            {
                                                                populate( "state", args );  // end state
                                                            }
                              ;



//---------------------------------------------------------
// Statements
//---------------------------------------------------------

statement
//returns [Statement st]
                              : ^( STATEMENT
                                   ( codeBlock       
                                   | assignmentStatement    
                                   | streamStatement        
                                   | callStatement          
                                   | exitStatement          
                                   | returnStatement        
                                   | delayStatement         
                                   | raiseStatement         
                                   | deleteStatement        
                                   | eraseStatement         
                                   | linkStatement          
                                   | scheduleStatement      
                                   | cancelTimerStatement   
                                   | generateStatement      
                                   | ifStatement            
                                   | caseStatement          
                                   | forStatement           
                                   | whileStatement         
                                   |                        
                                   )
                                   pragmaList["omit"]               
                                 )
                              ;

statementList
//returns [List<Statement> statements = new ArrayList<Statement>()]
                              : ^( STATEMENT_LIST
                                   ( statement                 
                                   )*
                                 )
                              ;


assignmentStatement
//returns [AssignmentStatement st]
                              : ^( ASSIGN
                                   lhs=expression rhs=expression
                                 )                          
                              ;

streamStatement
//returns [IOStreamStatement st]

                              : ^( STREAM_STATEMENT
                                   expression
                                   ( streamOperator         
                                   )+
                                 )                          
                              ;

streamOperator
//returns [IOStreamStatement.IOExpression op]

                              : ^( ( STREAM_IN              
                                   | STREAM_OUT             
                                   | STREAM_LINE_IN         
                                   | STREAM_LINE_OUT        
                                   ) expression
                                 )                          
                              ;

callStatement
//returns [Statement st]

                              : ^( CALL
                                   expression               
                                   ( argument               
                                   )*                       
                                 )                          

                              ;


exitStatement
//returns [ExitStatement st]
                              : ^( EXIT
                                   condition?
                                 )                          
                              ;

returnStatement
//returns [ReturnStatement st]
                              : ^( RETURN
                                   expression              
                                 )                          
                              ;

delayStatement
//returns [DelayStatement st]
                              : ^( DELAY
                                   expression
                                 )                         
                              ;

raiseStatement
//returns [RaiseStatement st]
                              : ^( RAISE
                                   exceptionReference
                                   expression?
                                 )                          
                              ;

deleteStatement
//returns [DeleteStatement st]
                              : ^( DELETE
                                   expression
                                 )                          
                              ;

eraseStatement
//returns [EraseStatement st]
                              : ^( ERASE
                                   expression
                                 )                          
                              ;

linkStatement
//returns [LinkUnlinkStatement st]
                              : ^( linkStatementType
                                   lhs=expression      
                                   relationshipSpec//[$lhs.exp,false,false]
                                   (rhs=expression
                                    assoc=expression? )?
                                 )                          
                              ;

linkStatementType
//returns [LinkUnlinkStatement.Type type, Position pos]
                              : LINK                        
                              | UNLINK                      
                              ;


cancelTimerStatement
//returns [CancelTimerStatement st]
                             : ^( CANCEL
                                  timerId=expression )    
                             ;
                              
scheduleStatement
//returns [ScheduleStatement st]
                              : ^( SCHEDULE
                                   timerId=expression
                                   generateStatement
                                   scheduleType
                                   time=expression
                                   period=expression?
                                 )                         
                              ;
scheduleType
//returns [boolean isAbsolute]
                              : AT											    
                              | DELAY									      
                              ;



generateStatement
//returns [GenerateStatement st]

                              : ^( GENERATE
                                   eventReference
                                   ( argument               
                                   )*                       
                                   expression? )            
                              ;

ifStatement
//returns [IfStatement st]

                              : ^( IF
                                   condition
                                   statementList            
                                   ( elsifBlock             
                                   )*              
                                   ( elseBlock              
                                   )?
                                 )                          
                              ;


elsifBlock
//returns [IfStatement.Branch branch]
                              : ^( ELSIF
                                   condition
                                   statementList )          
                              ;

elseBlock
//returns [IfStatement.Branch branch]
                              : ^( ELSE
                                   statementList )          
                              ;


whileStatement
//returns [WhileStatement st]
                              : ^( WHILE
                                   condition
                                   statementList )          
                              ;

condition
//returns [Expression exp]      
                              : ^( CONDITION
                                   expression )             
                              ;


caseStatement
//returns [CaseStatement st]      

                              :^( CASE
                                  expression
                                  ( caseAlternative         
                                  )*
                                  ( caseOthers              
                                  )?
                                )                           
                              ;

caseAlternative
//returns [CaseStatement.Alternative alt]

                              : ^( WHEN                     
                                   ( choice                 
                                   )+
                                   statementList )         
                              ;

choice
//returns [Expression exp]      
                              : ^( CHOICE
                                   expression)              
                              ;

caseOthers
//returns [CaseStatement.Alternative alt]
                              : ^( OTHERS
                                   statementList )          
                              ;

forStatement
//returns [ForStatement st]
//scope NameScope;
                              : ^( FOR
                                   loopVariableSpec         
                                   ^( STATEMENT_LIST 
                                      ( statement               
                                      )*
                                    ) 
                                 )
                              ;

loopVariableSpec
//returns [LoopSpec spec]
                              : ^( LOOP_VARIABLE
                                   identifier
                                   REVERSE?
                                   expression )             
                              ;



//---------------------------------------------------------
// Code Blocks
//---------------------------------------------------------

codeBlock
//returns [ CodeBlock st ]
//scope NameScope;
                              :^( CODE_BLOCK                
                                  ( variableDeclaration     
                                  )*     
                                  ^(STATEMENT_LIST ( statement               
                                  )* )
                                  ( exceptionHandler        
                                  )*
                                  ( otherHandler            
                                  )?
                                )
                              ;



variableDeclaration
//returns [VariableDefinition var]
                              : ^( VARIABLE_DECLARATION
                                   variableName
                                   READONLY?
                                   typeReference
                                   expression?
                                   pragmaList["omit"] )             
                              ;


exceptionHandler
//returns [ExceptionHandler handler]
                              : ^( EXCEPTION_HANDLER
                                   exceptionReference       
                                   ^(STATEMENT_LIST ( statement               
                                   )* )
                                 )
                              ;

otherHandler
//returns [ExceptionHandler handler]
                              : ^( OTHER_HANDLER            
                                   ^(STATEMENT_LIST ( statement              
                                   )* )
                                 )
                              ;

variableName
returns [String name]
                              : ^( VARIABLE_NAME
                                   identifier )             
                              ;

//---------------------------------------------------------
// Expression Definition
//---------------------------------------------------------


expression
returns [Object expression]
@after
                                                            {
                                                                try {
                                                                  $expression = loader.create( "Expression" );
                                                                } catch ( XtumlException e ) { System.err.println( e ); }
                                                            }
                              : binaryExpression            
                              | unaryExpression             
                              | rangeExpression             
                              | aggregateExpression         
                              | linkExpression              
                              | navigateExpression          
                              | correlateExpression         
                              | orderByExpression           
                              | createExpression            
                              | findExpression              
                              | dotExpression               
                              | terminatorServiceExpression 
                              | callExpression              
                              | sliceExpression             
                              | primeExpression             
                              | nameExpression              
                              | literalExpression           
                              ;

binaryExpression
//returns [BinaryExpression exp]
                              : ^( binaryOperator
                                   lhs=expression
                                   rhs=expression
                                 )                          
                              ;


binaryOperator
//returns [BinaryExpression.OperatorRef op]
                              : AND                                        
                              | CONCATENATE                 
                              | DISUNION                    
                              | DIVIDE                      
                              | EQUAL                       
                              | GT                          
                              | GTE                         
                              | INTERSECTION                
                              | LT                          
                              | LTE                         
                              | MINUS                       
                              | MOD                         
                              | NOT_EQUAL                   
                              | NOT_IN                      
                              | OR                          
                              | PLUS                        
                              | POWER                       
                              | REM                         
                              | TIMES                       
                              | UNION                       
                              | XOR                         
                              ;

unaryExpression
//returns [UnaryExpression exp]
                              :^( unaryOperator 
                                  expression
                                )                           
                              ;

unaryOperator
//returns [UnaryExpression.OperatorRef op]
                              : UNARY_PLUS                  
                              | UNARY_MINUS                 
                              | NOT                         
                              | ABS                         
                              ;


rangeExpression
//returns [MinMaxRange exp]
                              : ^( RANGE_DOTS
                                   from=expression
                                   to=expression
                                 )                          
                              ;




aggregateExpression
//returns [StructureAggregate exp]

                              : ^( AGGREGATE
                                   ( expression             
                                   )+ 
                                 )                          
                              ;


linkExpression
//returns [LinkUnlinkExpression exp]
                              : ^( linkExpressionType
                                   lhs=expression      
                                   relationshipSpec//[$lhs.exp,false,false]
                                   rhs=expression?
                                 )                          
                              ;
linkExpressionType
//returns [LinkUnlinkExpression.Type type, Position pos]
                              : LINK                        
                              | UNLINK                      
                              ;


navigateExpression
//returns [NavigationExpression exp]
//scope WhereClauseScope;
                              : ^( NAVIGATE
                                   expression
                                   relationshipSpec//[$expression.exp,true,false]
                                                            
                                   ( whereClause           
                                   )?
                                 )                          
                                                                                          
                              ;

correlateExpression
//returns [CorrelatedNavExpression exp]
                              : ^( CORRELATE
                                   lhs=expression
                                   rhs=expression
                                   relationshipSpec//[$lhs.exp,true,true]
                                 )                          
                              ;



orderByExpression
//returns [OrderingExpression exp]

                              : ^( ( ORDERED_BY             
                                   | REVERSE_ORDERED_BY     
                                   ) 
                                   expression               
                                   ( sortOrder              
                                   )* 
                                 )                          
                              ;

sortOrder
//returns [String component, boolean reverse]
                              : ^( SORT_ORDER_COMPONENT
                                   REVERSE?
                                   identifier               
                                 )
                              ;

createExpression
//returns [CreateExpression exp]

                              : ^( CREATE
                                   objectReference 
                                   ( createArgument//[$objectReference.ref]         
                                   )*
                                 )                          
                              ;

createArgument //[ObjectNameExpression object]
//returns [CreateExpression.CreateAggregateValue arg]
                              : ^( CREATE_ARGUMENT
                                   attributeName
                                   expression )              
                              | ^( CURRENT_STATE
                                   stateName )               
                              ;

findExpression
//returns [FindExpression exp]
//scope WhereClauseScope;
                              : ^( findType
                                   expression               
                                   whereClause
                                 )                          
                              ;

whereClause
//returns [Expression exp]
                              : ^( WHERE
                                   ( expression             
                                   )?
                                 )
                              ;

findType
//returns [ FindExpression.ImplType type, Position pos ]
                              : FIND                        
                              | FIND_ONE                    
                              | FIND_ONLY                   
                              ;


dotExpression
//returns [Expression exp]
                              : ^( DOT
                                   expression
                                   identifier
                                 )                          
                              ;

terminatorServiceExpression
//returns [Expression exp]
                              : ^( TERMINATOR_SCOPE
                                   expression
                                   identifier
                                 )                          
                              ;

callExpression
//returns [Expression exp]

                              : ^( CALL
                                   expression               
                                   ( argument               
                                   )*                       
                                 )                          

                              ;

nameExpression
//returns [Expression exp]      
                              : ^( NAME
                                   identifier
                                 )                                
                              | ^( NAME
                                   domainReference
                                   identifier
                                 )                          
                              | ^( FIND_ATTRIBUTE
                                   identifier )             
                              | compoundTypeName            
                              ;


compoundTypeName
//returns [BasicType type]  
                              : instanceTypeRef             
                              | sequenceTypeRef             
                              | arrayTypeRef                
                              | setTypeRef                  
                              | bagTypeRef                  
                              ;


argument
//returns [Expression arg]
                              : ^( ARGUMENT
                                   expression
                                 )                          
                              ;

sliceExpression
//returns [Expression exp]
                              : ^( SLICE
                                   prefix=expression
                                   slice=expression
                                 )                          
                              ;

primeExpression
//returns [Expression exp]

                              : ^( PRIME
	                                 expression
                                   identifier
                                   ( argument               
                                   )*                       
                                 )                          
                              ;

literalExpression
returns [String exp]
//returns [Expression exp]
                              : IntegerLiteral              { $exp = $IntegerLiteral.text; }
                              | RealLiteral                 { $exp = $RealLiteral.text; }
                              | CharacterLiteral            { $exp = $CharacterLiteral.text; }
                              | StringLiteral               { $exp = $StringLiteral.text; }
                              | TimestampLiteral            { $exp = $TimestampLiteral.text; }
                              | DurationLiteral             { $exp = $DurationLiteral.text; }
                              | TRUE                        { $exp = $TRUE.text; }
                              | FALSE                       { $exp = $FALSE.text; }
                              | NULL                        { $exp = $NULL.text; }
                              | FLUSH                       { $exp = $FLUSH.text; }
                              | ENDL                        { $exp = $ENDL.text; }
                              | THIS                        { $exp = $THIS.text; }
                              | CONSOLE                     { $exp = $CONSOLE.text; }
                              ; 