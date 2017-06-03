dirname(@__FILE__) ∉ LOAD_PATH && push!(LOAD_PATH, dirname(@__FILE__))

using NetLogo

NetLogo.init(joinpath(homedir(), "bin/netlogo/6.0.1/app"))
w = NetLogo.newWorkspace()
NetLogo.open(w, "models/Sample Models/Earth Science/Fire.nlogo")
NetLogo.command(w, "set density 62")
NetLogo.command(w, "random-seed 0")
NetLogo.command(w, "setup")
NetLogo.command(w, "repeat 50 [ go ]")
println(NetLogo.report(w, "burned-trees"))
NetLogo.dispose(w)
