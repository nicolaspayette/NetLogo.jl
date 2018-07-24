module NetLogo

using JavaCall

const JDouble  = JavaObject{Symbol("java.lang.Double")}
const LogoList = JavaObject{Symbol("org.nlogo.core.LogoList")}
const Agent    = JavaObject{Symbol("org.nlogo.api.Agent")}

export JDouble, LogoList, Agent

function init(nlpath)
  cd(nlpath)
  if JavaCall.isloaded()
    warn("JVM already initialized.")
  else
    foreach(JavaCall.addOpts, ["-Xmx1024m", "-Dfile.encoding=UTF-8"])
    JavaCall.addClassPath(joinpath(nlpath, "*"))
    JavaCall.init()
  end
end

function companion{T}(t::Type{JavaCall.JavaObject{T}})
  const O = JavaObject{Symbol(string(T) * "\$")}
  jfield(O, "MODULE\$", O)
end

HeadlessWorkspace = @jimport org.nlogo.headless.HeadlessWorkspace

newWorkspace() = jcall(companion(HeadlessWorkspace), "newInstance", HeadlessWorkspace, ())
command(w, source) = jcall(w, "command", Void, (JString,), source)
report(w, source) = unpack(jcall(w, "report", JObject, (JString,), source))
open(w, modelname) = jcall(w, "open", Void, (JString,), modelname)
dispose(w) = jcall(w, "dispose", Void, ())

function withworkspace(f)
  w = newWorkspace()
  try
    f(w)
  finally
    dispose(w)
  end
end

function withmodel(f, modelname)
  withworkspace() do w
    open(w, modelname)
    f(w)
  end
end

function unpack(o::JavaObject)
  realclass = ccall(JavaCall.jnifunc.GetObjectClass, Ptr{Void},
    (Ptr{JavaCall.JNIEnv}, Ptr{Void}), JavaCall.penv, o.ptr)
  is(t) = JavaCall.isConvertible(t, realclass)
  to(t) = convert(t, o)
  if is(JDouble)
    jcall(to(JDouble), "doubleValue", jdouble, ())
  elseif is(JString)
    JavaCall.unsafe_string(to(JString))
  elseif is(LogoList)
    to(LogoList)
  elseif is(Agent)
    println("agent!")
    to(Agent)
  else
    o
  end
end

Base.length(lst::LogoList) = jcall(lst, "length", jint, ())
Base.getindex(lst::LogoList, i::Int) = unpack(jcall(lst, "get", JObject, (jint,), i - 1))
Base.getindex(lst::LogoList, range::Range) = [getindex(lst, i) for i = range]
Base.endof(lst::LogoList) = Base.length(lst)
Base.start(::LogoList) = 1
Base.next(lst::LogoList, state) = (getindex(lst, state), state + 1)
Base.done(lst::LogoList, state) = state > endof(lst)

type UndefinedVariableError <: Exception
  variable::String
end
UndefinedVariableError(jvariable::JString) = UndefinedVariableError(JavaCall.unsafe_string(jvariable))
Base.showerror(io::IO, e::UndefinedVariableError) = print(io, "Nothing named $(e.variable) has been defined.");

function indexofvariable(a::Agent, variable::String)
  const W = JavaObject{Symbol("org.nlogo.agent.World")}
  const A = JavaObject{Symbol("org.nlogo.agent.Agent")}
  agent = convert(A, a)
  world = jcall(agent, "world", W, ())
  jvariable = JString(uppercase(variable)) # TODO: uppercase conversion should be done on JVM side to be safe
  zerobasedindex = jcall(world, "indexOfVariable", jint, (A, JString), agent, jvariable)
  zerobasedindex == -1 ? throw(UndefinedVariableError(jvariable)) : zerobasedindex + 1
end

Base.length(a::Agent) = length(jcall(a, "variables", Array{JObject, 1}, ()))
Base.getindex(a::Agent, i::Int) = unpack(jcall(a, "getVariable", JObject, (jint,), i - 1))
Base.getindex(a::Agent, range::Range) = [getindex(a, i) for i = range]
Base.getindex(a::Agent, variable::String) = getindex(a, indexofvariable(a, variable))
Base.endof(a::Agent) = Base.length(a)
Base.start(::Agent) = 1
Base.next(a::Agent, state) = (getindex(a, state), state + 1)
Base.done(a::Agent, state) = state > endof(a)

end
