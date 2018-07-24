# NetLogo.jl

This package is meant to allow controlling [NetLogo](http://ccl.northwestern.edu/netlogo/) from [Julia](https://julialang.org/).

**Warning:** This is very much a work in progress and almost comically raw. It's also been on the backburner for a little while. Still, issues and pull requests are most welcome. If there is interest in the community, we might turn this into something useful...

# TODO

The first goal should be, for now, feature parity with [RNetLogo](https://cran.r-project.org/web/packages/RNetLogo/index.html), the [NetLogo Mathematica link](https://ccl.northwestern.edu/netlogo/docs/mathematica.html), and [pyNetLogo](https://github.com/quaquel/pyNetLogo), with the limitation that, at first, only 2d headless workspaces will be supported (i.e., no GUI, no 3d).

Except for raw types, the general strategy should be to provide interfaces to objects still living on the JVM rather than make copies. This should save memory and, in the case of mutable entities (i.e., agents), allow changes on the NetLogo side to show up in Julia.

This means that, among other things, we should:

- expose NetLogo agents as Julia data structures.

  At the moment, we have implemented the "iterable" and "indexable" interfaces, but it might be worth considering turning NetLogo agents into Julia associative collections.

- expose NetLogo lists and agentsets as proper Julia iterables.
- expose NetLogo agentsets as Julia IterableTables.
- expose NetLogo `patches` agentset as a Julia matrix.
- and maybe expose NetLogo networks of links and agents through a Julia graph library.

As a long term goal, exposing most of `org.nlogo.api` would make sense. `JavaCall.jl` being fairly low level, a lot of scaffolding would be required to make this easy to use.
