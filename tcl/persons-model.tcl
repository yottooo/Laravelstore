################## Data Model ################

nx::Class create Person {
  :property name:required
  :property birthday
}

nx::Class create Student -superclass Person {
  :property matnr:required
  :property {oncampus:boolean true}
}

################## Data instances ################
Person create p1 -name Bob
Student create s1 -name Susan -matnr 4711
Student create s2 -name Mike -matnr 4712
Student create s3 -name Luna -matnr 4713
Person create p2 -name Fred
Student create s5 -name Jane -matnr 4716
Person create p3 -name Nina
