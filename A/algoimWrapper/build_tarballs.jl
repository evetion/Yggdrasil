using BinaryBuilder, Pkg

# See https://github.com/JuliaLang/Pkg.jl/issues/2942 
# Once this Pkg issue is resolved, this must be removed
uuid = Base.UUID("a83860b7-747b-57cf-bf1f-3e79990d037f")
delete!(Pkg.Types.get_last_stdlibs(v"1.6.3"), uuid)

# needed for libjulia_platforms and julia_versions
include("../../L/libjulia/common.jl")

name = "algoimWrapper"
version = v"0.3.1"

sources = [
    GitSource("https://github.com/ericneiva/algoimWrapper.git", "b7ce0d93f25f5f2261c6ca36b1b71a041ecb72ed"),
    DirectorySource("./bundled"),
]

script = raw"""
cd ${WORKSPACE}/srcdir/algoimWrapper
mkdir build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX=${prefix} \
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
    -DJulia_PREFIX=${prefix} \
    -DBLAS_LIBRARIES="${libdir}/libopenblas.${dlext}" \
    ..
VERBOSE=ON cmake --build . --config Release --target install -- -j${nproc}
"""

platforms = vcat(libjulia_platforms.(julia_versions)...)
# FreeBSD on 64bit ARM 64 is not supported by algoimWrapper
platforms = filter(p -> !(Sys.isfreebsd(p) && arch(p) == "aarch64"), platforms)
platforms = expand_cxxstring_abis(platforms)

products = [
    LibraryProduct("libalgoimwrapper", :libalgoimwrapper),
]

dependencies = [
    BuildDependency("algoim_jll"),
    BuildDependency("libjulia_jll"),
    Dependency("libcxxwrap_julia_jll"; compat="0.13.2"),
    Dependency("OpenBLAS32_jll"), # links to LAPACKE
]

build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies;
    preferred_gcc_version=v"8", julia_compat="1.6")
