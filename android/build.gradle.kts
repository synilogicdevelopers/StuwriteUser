allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Kotlin 2.2+ defaults plugin Kotlin code to the JDK's target (21) while some
// plugins (e.g. flutter_facebook_auth) compile their Java code for 1.8, which
// Gradle rejects. Align each module's Kotlin target with its Java target.
subprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        // e.g. compileReleaseKotlin -> compileReleaseJavaWithJavac
        val javaTask = project.tasks.findByName(name.removeSuffix("Kotlin") + "JavaWithJavac") as? JavaCompile
        val javaTarget = javaTask?.targetCompatibility
        if (javaTarget != null) {
            compilerOptions.jvmTarget.set(
                org.jetbrains.kotlin.gradle.dsl.JvmTarget.fromTarget(javaTarget)
            )
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}