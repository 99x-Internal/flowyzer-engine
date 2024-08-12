
ALTER TABLE "flowyzer_users_roles_associations" ADD FOREIGN KEY ("user_id") REFERENCES "flowyzer_users" ("id");

ALTER TABLE "flowyzer_users_roles_associations" ADD FOREIGN KEY ("role_id") REFERENCES "flowyzer_user_roles" ("id");

ALTER TABLE "flowyzer_teams" ADD FOREIGN KEY ("organization_id") REFERENCES "flowyzer_organizations" ("id");

ALTER TABLE "flowyzer_dashboards" ADD FOREIGN KEY ("team_id") REFERENCES "flowyzer_teams" ("id");

ALTER TABLE "flowyzer_connections" ADD FOREIGN KEY ("dashboard_id") REFERENCES "flowyzer_dashboards" ("id");

ALTER TABLE "flowyzer_syncs" ADD FOREIGN KEY ("connection_id") REFERENCES "flowyzer_connections" ("id");

ALTER TABLE "flowyzer_user_organizations" ADD FOREIGN KEY ("user_id") REFERENCES "flowyzer_users" ("id");

ALTER TABLE "flowyzer_user_organizations" ADD FOREIGN KEY ("organization_id") REFERENCES "flowyzer_organizations" ("id");