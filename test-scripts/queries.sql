-- ============================================================================
-- TEST-SKRIPT FOR OBLIG 1
-- ============================================================================

-- Kjør med: docker compose exec postgres psql -U admin -d oblig01 -f test-scripts/queries.sql

-- En test med en SQL-spørring mot metadata i PostgreSQL (kan slettes fra din script)
    select nspname as schema_name
    from pg_catalog.pg_namespace
    order by schema_name;
