allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Patch packages that are missing the Android namespace required by AGP 8+
val namespacePatch = mapOf(
    "record" to "com.llfbandit.record",
)
subprojects {
    val ns = namespacePatch[project.name] ?: return@subprojects
    pluginManager.withPlugin("com.android.library") {
        extensions.getByType(com.android.build.gradle.LibraryExtension::class.java).apply {
            if (namespace == null) namespace = ns
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
