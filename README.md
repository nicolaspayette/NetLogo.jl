# TODO

The first goal should be, for now, feature parity with RNetLogo and the NetLogo Mathematica link, with the limitation that, at first, only 2d headless workspaces will be supported (i.e., no GUI, no 3d).

Except for raw types, the general strategy should be to provide interfaces to objects still living on the JVM rather than make copies. This should save memory and, in the case of mutable entities (i.e., agents), allow changes on the NetLogo side to show up in Julia.

This means that, among other things, we should:

- expose NetLogo agents as Julia data structures (which one remains to be determined);
- expose NetLogo lists and agentsets as proper Julia iterables.
- expose NetLogo agentsets as Julia IterableTables.
- and maybe expose NetLogo networks of links and agents through a Julia graph library.

As a long term goal, exposing most of `org.nlogo.api` would make sense. `JavaCall.jl` being fairly low level, a lot of scaffolding would be required to make this easy to use.
