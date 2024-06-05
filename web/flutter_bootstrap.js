{{ flutter_js }}
{{ flutter_build_config }}

if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register("/firebase-messaging-sw.js");
}

// Download main.dart.js
_flutter.loader.load({
    serviceWorkerSettings: {
        serviceWorkerVersion: {{ flutter_service_worker_version }},
    },
    onEntrypointLoaded: async function (engineInitializer) {
        const appRunner = await engineInitializer.initializeEngine()
        await appRunner.runApp()
    }
});