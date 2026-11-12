/// Lifecycle status of a demand (spec §7.1).
///
/// The values derive from `docs/API_CONTRACT.md` §6 (`ABERTA`,
/// `EM_ANDAMENTO`, `RESOLVIDA`, `REJEITADA`). "Encaminhada" is a UI label for
/// [StatusDemanda.emAndamento], not a domain value (spec assumption A6); the
/// presentation mapping lives in `StatusChip`.
enum StatusDemanda { aberta, emAndamento, resolvida, rejeitada }
