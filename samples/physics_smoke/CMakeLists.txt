add_executable(JobSysProof
    jobsys_proof.cpp
)
target_compile_features(JobSysProof PRIVATE cxx_std_20)
target_link_libraries(JobSysProof PRIVATE Luth::Luth Jolt::Jolt Tracy::TracyClient)

luth_enable_tracy_fibers(JobSysProof)
luth_enable_asan(JobSysProof)
luth_set_output_directories(JobSysProof)
set_property(TARGET JobSysProof PROPERTY FOLDER "Samples")
