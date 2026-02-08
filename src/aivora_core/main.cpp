#include "crow.h"
#include <iostream>

int main() {
    crow::SimpleApp app;

    CROW_ROUTE(app, "/v1/sniper/qualify").methods("POST"_method)
    ([](const crow::request& req){
        auto data = crow::json::load(req.body);
        if (!data) return crow::response(400);

        int lead_score = 0;
        if (data["income"].i() >= 15000) lead_score += 60;
        if (data["verified"].b()) lead_score += 40;

        crow::json::wrow response;
        response["score"] = lead_score;
        response["priority"] = (lead_score >= 80) ? "CRITICAL" : "NORMAL";
        response["engine"] = "Aivora-CPP-Core-v1";

        return crow::response(response);
    });

    app.port(8080).multithreaded().run();
}
