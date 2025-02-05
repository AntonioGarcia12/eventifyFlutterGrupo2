const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

admin.initializeApp();

exports.enviarRecordatorioEvento = functions.pubsub
    .schedule("every 10 minutes")
    .timeZone("Europe/Madrid")
    .onRun(async (context) => {
        const ahora = Date.now();
        const unaHoraEnMs = 3600 * 1000;
        const tolerancia = 5 * 60 * 1000;
        const targetTimeMillis = ahora + unaHoraEnMs;
        const lowerBoundMillis = targetTimeMillis - tolerancia;
        const upperBoundMillis = targetTimeMillis + tolerancia;

        console.log(
            `Buscando eventos con start_time entre: 
      ${new Date(lowerBoundMillis).toISOString()} y 
      ${new Date(upperBoundMillis).toISOString()}`,
        );

        try {
            const eventosSnapshot = await admin.firestore()
                .collection("event_registrations")
                .where(
                    "start_time",
                    ">=",
                    admin.firestore.Timestamp.fromMillis(lowerBoundMillis),
                )
                .where(
                    "start_time",
                    "<=",
                    admin.firestore.Timestamp.fromMillis(upperBoundMillis),
                )
                .get();

            if (eventosSnapshot.empty) {
                console.log("No se encontraron eventos");
                return null;
            }

            console.log(`Eventos encontrados: ${eventosSnapshot.size}`);

            for (const eventoDoc of eventosSnapshot.docs) {
                const eventoData = eventoDoc.data();
                const usuariosRegistrados = eventoData.fcm_token || [];
                const tituloEvento = eventoData.
                    event_title || "Evento sin título";

                if (!Array.isArray(usuariosRegistrados) ||
                    usuariosRegistrados.length === 0) {
                    console.log(`Evento "${tituloEvento}" 
            sin usuarios registrados. Saltando...`);
                    continue;
                }

                console.log(`Procesando evento "${tituloEvento}" 
            con ${usuariosRegistrados.length} usuarios`);

                let exitos = 0;
                let fallos = 0;

                for (const token of usuariosRegistrados) {
                    try {
                        if (typeof token !== "string" ||
                            !token.startsWith("c")) {
                            console.error(`Token inválido: ${token}`);
                            fallos++;
                            await eventoDoc.ref.update({
                                fcm_token: admin.
                                    firestore.FieldValue.arrayRemove(token),
                            });
                            continue;
                        }

                        await admin.messaging().send({
                            notification: {
                                title: "¡El evento está a punto de comenzar!",
                                body: `${tituloEvento} comienza en 1 hora`,
                            },
                            token: token,
                        });

                        exitos++;
                        console.log(`Notificación enviada a 
                ${token.substring(0, 10)}...`);

                        await eventoDoc.ref.update({
                            fcm_token: admin.
                                firestore.FieldValue.arrayRemove(token),
                        });
                    } catch (error) {
                        fallos++;
                        console.error(`Error enviando a 
                            ${token.substring(0, 10)}...:`, error.message);

                        if (
                            error.code ===
                "messaging/invalid-registration-token" ||
                error.code ===
                "messaging/registration-token-not-registered"
                        ) {
                            console.log(`Eliminando token inválido: 
                ${token.substring(0, 10)}...`);
                            await eventoDoc.ref.update({
                                fcm_token: admin
                                    .firestore.FieldValue.arrayRemove(token),
                            });
                        }
                    }
                }

                console.log(`Resumen para "
            ${tituloEvento}": ${exitos} exitos, ${fallos} fallos`);
            }
        } catch (error) {
            console.error("Error crítico al procesar eventos:", error.message);
        }
    });
