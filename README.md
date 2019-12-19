# Notes


## Principles

- model is persisted by Datastore, which hides the actual storage implementation, and the synchronisation mechanism
- the user interface effectively displays immutable copies of the model; it does not work with it directly 
- read access to the model is asynchronous; the UI request the properties it needs, and displays them when they are delivered
- updates to the model can happen in two ways: internally via user initiated actions, or externally via synchronisation with other devices
- the user interface needs to listen for model changes and refresh itself when they occur, by re-requesting the properties/entities it needs
- modifications of the model by the application are done indirectly via actions
- actions are undoable, recordable, and replayable
- actions can potentially be invoked by scripts or used by other tools to modify the datastore 
- actions are always asynchronous; the user interface can invoke them, but if it wants to update in response to the result, it needs to listen for completion of the action


## Separation Of Concerns

When switching to using Datastore, I realised that the previous code was heavily entangled with CoreData.

Model objects were created directly, by passing in a core data context. The context was typically obtained from the CollectionContainer, but that step was done outside the container code, exposing the implementation.

With the new design, we want to hide the storage mechanism inside the container as much as possible.

Therefore, all model objects should be vended by the container:

- CollectionContainer is the abstraction for a collection
- ModelObject is the abstraction for the objects a collection contains
- Book, Person, etc are subclasses of ModelObject
- finding/creating model objects should always be done via a collection, using e:g `collection.person(named: "Test")`; this decouples the creation of model objects from the underlying representation as they are never constructed explicitly
