using NetLogo

NetLogo.init(joinpath(homedir(), "bin/netlogo/6.0.4/app"))
NetLogo.withmodel("models/Sample Models/Biology/Moths.nlogo") do w
  NetLogo.command(w, "setup")
  light = NetLogo.report(w, "one-of lights")
  @show light
  @show light["intensity"]
  Base.length(light)
  println(collect(light))
end
