plugins {
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}

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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// --- SINGLE COMBINED SUBPROJECTS BLOCK ---
subprojects {
    // Logic from the first block
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // REMOVED this line as it conflicts with afterEvaluate
    // project.evaluationDependsOn(":app")

    // Logic from the second block
    afterEvaluate {
        // Find if the subproject has an Android configuration
        val androidExtension = project.extensions.findByType(com.android.build.gradle.BaseExtension::class.java)
        if (androidExtension != null) {
            // If it has one, check if the namespace is missing
            if (androidExtension.namespace == null) {
                // Assign a namespace based on the project's group, or a fallback
                val group = (project.group as? String) ?: "com.example.${project.name}"
                androidExtension.namespace = group
            }
        }
    }
}