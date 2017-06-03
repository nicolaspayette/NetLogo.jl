module NetLogo

using JavaCall

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
  typealias O JavaObject{Symbol(string(T) * "\$")}
  jfield(O, "MODULE\$", O)
end

HeadlessWorkspace = @jimport org.nlogo.headless.HeadlessWorkspace

newWorkspace() = jcall(companion(HeadlessWorkspace), "newInstance", HeadlessWorkspace, ())
command(w, source) = jcall(w, "command", Void,    (JString,), source)
report(w, source) = unpack(jcall(w, "report",  JObject, (JString,), source))
open(w, modelname) = jcall(w, "open", Void, (JString,), modelname)
dispose(w) = jcall(w, "dispose", Void, ())

function unpack(o::JavaObject)
  typealias JDouble JavaObject{Symbol("java.lang.Double")}
  realclass = ccall(JavaCall.jnifunc.GetObjectClass, Ptr{Void},
    (Ptr{JavaCall.JNIEnv}, Ptr{Void}), JavaCall.penv, o.ptr)
  is(t) = JavaCall.isConvertible(t, realclass)
  to(t) = convert(t, o)
  if is(JDouble)
    jcall(to(JDouble), "doubleValue", jdouble, ())
  elseif is(JString)
    JavaCall.unsafe_string(to(JString))
  else
    o
  end
end

end
