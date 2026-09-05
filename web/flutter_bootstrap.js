{{flutter_js}}
{{flutter_build_config}}

// main.dart.js also has a fixed filename. A unique query guarantees that a
// newly published PECHATE build is loaded instead of an older CDN response.
for (const build of _flutter.buildConfig.builds) {
  if (build.mainJsPath) {
    build.mainJsPath = `${build.mainJsPath}?v=${Date.now()}`;
  }
}

_flutter.loader.load();
