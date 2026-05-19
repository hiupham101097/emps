allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Thiết lập thư mục build (Giữ nguyên logic của bạn)
val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // 1. ÉP PHIÊN BẢN SDK: Sửa lỗi yêu cầu SDK 34 của các thư viện androidx
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            if (android.compileSdkVersion == "android-31" || android.compileSdkVersion == "android-33") {
                android.compileSdkVersion(34)
            }
        }
    }

    // 2. ÉP PHIÊN BẢN DESUGAR: Sửa lỗi Dependency ':flutter_local_notifications'
    configurations.all {
        resolutionStrategy {
            force("com.android.tools:desugar_jdk_libs:2.1.4")
        }
    }
}

// Bỏ dòng evaluationDependsOn(":app") vì nó thường gây lỗi vòng lặp (Circular dependency)
// subprojects { project.evaluationDependsOn(":app") } 

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}