module AppointmentsHelper
  STATUS_BADGES = {
    "pending"   => { label: "Pendente",   classes: "bg-amber-50 text-amber-700 ring-amber-600/20" },
    "confirmed" => { label: "Confirmado", classes: "bg-emerald-50 text-emerald-700 ring-emerald-600/20" },
    "cancelled" => { label: "Cancelado",  classes: "bg-rose-50 text-rose-700 ring-rose-600/20" },
    "expired"   => { label: "Expirado",   classes: "bg-slate-100 text-slate-600 ring-slate-500/20" }
  }.freeze

  def status_badge(appointment)
    badge = STATUS_BADGES.fetch(appointment.expired? ? "expired" : appointment.status)

    content_tag :span, badge[:label],
      class: "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ring-1 ring-inset #{badge[:classes]}"
  end
end
