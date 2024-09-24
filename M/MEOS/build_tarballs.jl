# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "MEOS"
version = v"1.1.1"

# Collection of sources required to complete build
sources = [
    GitSource("https://github.com/MobilityDB/MobilityDB.git", "4273bdd4f70ee6fb8b28cd269385d83da6eeba31")
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/MobilityDB

cmake -B build -DCMAKE_INSTALL_PREFIX=${prefix} -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} -DCMAKE_BUILD_TYPE=Release -DMEOS=ON
cmake --build build --parallel ${nproc}
cmake --install build
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = expand_cxxstring_abis(supported_platforms())

# The products that we will ensure are always built
products = [
    LibraryProduct("libmeos", :libmeos)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency(PackageSpec(name="GEOS_jll", uuid="d604d12d-fa86-5845-992e-78dc15976526"))
    Dependency(PackageSpec(name="JSON_C_jll", uuid="9cdfc4e7-e793-5089-b6f7-569a57a60f0a"))
    Dependency(PackageSpec(name="Proj_jll", uuid="58948b4f-47e0-5654-a9ad-f609743f8632"))
    Dependency(PackageSpec(name="GSL_jll", uuid="1b77fbbe-d8ee-58f0-85f9-836ddc23a7a4"); compat="~2.7.2")
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.6", preferred_gcc_version=v"8")
