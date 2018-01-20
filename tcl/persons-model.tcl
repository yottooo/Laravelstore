################## Data Model ################

nx::Class create Person {
  :property name:required
  :property birthday
}

nx::Class create Student -superclass Person {
  :property matnr:required
  :property {oncampus:boolean true}
}
