// Formats every TypeSpec file through the compiler's own formatter.
// `tsp format` cannot run under Bun: it lists files with fs.glob and the
// `withFileTypes` option, which Bun does not implement.
import { Glob } from "bun";
import { formatTypeSpec } from "@typespec/compiler";

for await (const path of new Glob("**/*.tsp").scan({ dot: false })) {
  if (path.startsWith("node_modules/")) continue;
  const source = await Bun.file(path).text();
  const formatted = await formatTypeSpec(source);
  if (formatted !== source) {
    await Bun.write(path, formatted);
    console.log(`formatted ${path}`);
  }
}
