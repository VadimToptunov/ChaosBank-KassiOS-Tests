# Generates ChaosBankKassiOS.xcodeproj: the ChaosBank app (built from the
# submodule's source, clean profile) + a UI-test target that compiles the KassiOS
# sources directly and runs the KassiOS-driven UI tests against it.
#
# Run from the repo root: `ruby gen.rb`.
require "xcodeproj"

PROJECT = "ChaosBankKassiOS.xcodeproj"
project = Xcodeproj::Project.new(PROJECT)

def add(project, target, glob)
  refs = Dir.glob(glob).sort.map { |path| project.main_group.new_file(path) }
  target.add_file_references(refs)
end

# --- ChaosBank app (built from the submodule, clean profile) -----------------
app = project.new_target(:application, "ChaosBank", :ios, "17.0")
add(project, app, "vendor/ChaosBank/ChaosBank/**/*.swift")
assets = project.main_group.new_file("vendor/ChaosBank/ChaosBank/Assets.xcassets")
app.add_resources([assets])
app.build_configurations.each do |c|
  s = c.build_settings
  s["PRODUCT_BUNDLE_IDENTIFIER"] = "VadimToptunov.ChaosBank"
  s["GENERATE_INFOPLIST_FILE"] = "YES"
  s["INFOPLIST_KEY_UILaunchScreen_Generation"] = "YES"
  s["SWIFT_VERSION"] = "5.0"
  s["IPHONEOS_DEPLOYMENT_TARGET"] = "17.0"
  s["TARGETED_DEVICE_FAMILY"] = "1,2"
  s["MARKETING_VERSION"] = "1.0"
  s["CURRENT_PROJECT_VERSION"] = "1"
  s["CODE_SIGNING_ALLOWED"] = "NO"
  s["ENABLE_PREVIEWS"] = "YES"
  # Clean profile: only DEBUG (matches ChaosBank's Debug config — no
  # CHAOSBANK_PROFILE_* flag means zero baked defects; profiles are chosen at
  # launch instead via -ChaosBankProfile / -ChaosBankDefects).
  s["SWIFT_ACTIVE_COMPILATION_CONDITIONS"] = "DEBUG"
  s["ASSETCATALOG_COMPILER_APPICON_NAME"] = "AppIcon"
  s["ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME"] = "AccentColor"
  s["ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS"] = "YES"
  # ChaosBank is written "main actor by default" — match its own project so its
  # sources compile the same way here (only the app target; the UI-test target
  # keeps KassiOS's explicit isolation model).
  s["SWIFT_DEFAULT_ACTOR_ISOLATION"] = "MainActor"
  s["SWIFT_APPROACHABLE_CONCURRENCY"] = "YES"
  s["SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY"] = "YES"
end

# --- UI-test target ----------------------------------------------------------
uitests = project.new_target(:ui_test_bundle, "ChaosBankKassiOSUITests", :ios, "17.0")
add(project, uitests, "vendor/KassiOS/Sources/KassiOS/*.swift")   # compile KassiOS directly
add(project, uitests, "UITests/**/*.swift")
uitests.build_configurations.each do |c|
  s = c.build_settings
  s["PRODUCT_BUNDLE_IDENTIFIER"] = "VadimToptunov.ChaosBankKassiOSUITests"
  s["TEST_TARGET_NAME"] = "ChaosBank"
  s["GENERATE_INFOPLIST_FILE"] = "YES"
  s["SWIFT_VERSION"] = "5.0"
  s["IPHONEOS_DEPLOYMENT_TARGET"] = "17.0"
  s["TARGETED_DEVICE_FAMILY"] = "1,2"
  s["CODE_SIGNING_ALLOWED"] = "NO"
end
uitests.add_dependency(app)

project.save

scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app)
scheme.add_build_target(uitests)
scheme.add_test_target(uitests)
scheme.set_launch_target(app)
scheme.save_as(PROJECT, "ChaosBankKassiOSUITests", true)

puts "Generated #{PROJECT} (ChaosBank app + ChaosBankKassiOSUITests)"
