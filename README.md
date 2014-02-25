NSManagedObject+SYNC
====================

This is a simple NSManagedObject category that makes syncing with JSON dictionaries, or any other dictionaries much more simple. 

The idea is to create any easier way to sync NSManagedObjects with web services. Also to create a way to transfer relationships with the dictionary that can be serialized into JSON objects or any other transfer protocol.

How To Use
==========

To use this drag and drop NSManagedObject+SYNC.h/.m into your project and then add:

#import "NSManagedObject+SYNC.h"

to the header file of each NSManagedObject subclasses. Make sure that you create objectId's in each managed object. Also the relationships have a naming convention for now.

For one-to-one relationships name the relationship the other objects name all lowercase. For to-many relationships name the relationship the other objects name all lowercase with an 's' at the end.

For instance if I want to have a relationship between Choice and User and there is only one User per Choice. When I make that relationship I would name it user, but multiple Choice objects can be added to User so when you make that relationship for the User entity I would name it choices.

TODO
====

Transfer relationships without need of objectIds

Add relationships on update without specific relationship naming conventions.
