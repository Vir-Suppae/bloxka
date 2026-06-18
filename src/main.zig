const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

const v3 = rl.Vector3;

const cos = std.math.cos;
const sin = std.math.sin;

const f: v3 = .init(0, 0, 1);
const u: v3 = .init(0, 1, 0);
const r: v3 = .init(1, 0, 0);

const sensitivity: f32 = 0.005;

pub fn main(_: std.process.Init) !void {
    rl.setConfigFlags(.{
        .window_resizable = true,
    });
    rl.initWindow(100, 100, "bloxka");
    defer rl.closeWindow();
    rl.setTargetFPS(60);
    rl.maximizeWindow();

    rl.disableCursor();

    var cam: rl.Camera3D = .{
        .position = .init(0, 2, 0),
        .target = .init(1, 2, 0),
        .up = .init(0, 1, 0),
        .fovy = 60,
        .projection = .perspective,
    };

    var pos: v3 = .init(0, 2, 0);
    var rot: rl.Quaternion = .init(0, 0, 0, 1);

    while (!rl.windowShouldClose()) {
        const forward = f.rotateByQuaternion(rot);
        const up = u.rotateByQuaternion(rot);
        const right = r.rotateByQuaternion(rot);

        const md = rl.getMouseDelta();

        const yq = rl.Quaternion.fromAxisAngle(up, -md.x * sensitivity);
        const pq = rl.Quaternion.fromAxisAngle(right, md.y * sensitivity);

        rot = yq.multiply(rot);
        rot = pq.multiply(rot);

        rot = rot.normalize();

        const speed = 10.0 * rl.getFrameTime();

        if (rl.isKeyDown(.q)) rot = rl.Quaternion.fromAxisAngle(forward, -3.14 * rl.getFrameTime()).multiply(rot);
        if (rl.isKeyDown(.e)) rot = rl.Quaternion.fromAxisAngle(forward, 3.14 * rl.getFrameTime()).multiply(rot);

        if (rl.isKeyDown(.w)) pos = pos.add(forward.scale(speed));
        if (rl.isKeyDown(.s)) pos = pos.subtract(forward.scale(speed));

        if (rl.isKeyDown(.a)) pos = pos.add(right.scale(speed));
        if (rl.isKeyDown(.d)) pos = pos.subtract(right.scale(speed));

        cam.position = pos;
        cam.target = pos.add(forward);
        cam.up = up;

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.beginMode3D(cam);
        defer rl.endMode3D();

        rl.clearBackground(.ray_white);
        rl.drawGrid(10, 10);
    }
}
