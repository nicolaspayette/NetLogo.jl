dirname(@__FILE__) ∉ LOAD_PATH && push!(LOAD_PATH, dirname(@__FILE__))

using NetLogo

NetLogo.init(joinpath(homedir(), "bin/netlogo/6.0.1/app"))
NetLogo.withmodel("models/Sample Models/Biology/Moths.nlogo") do w
  NetLogo.command(w, "setup")
  light = NetLogo.report(w, "one-of lights")
  @show light
  @show light["intensity"]
  Base.length(light)
  println(collect(light))
end
