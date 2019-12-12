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

