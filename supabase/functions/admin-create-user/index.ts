import { createClient } from 'jsr:@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

type CreateUserBody = {
  username?: string
  password?: string
  full_name?: string
  display_name?: string
  role_id?: number
  nik?: string
  address?: string
  phone?: string
  contact_email?: string
  education?: string
  division_code?: string
  division_name?: string
}

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }
  if (request.method !== 'POST') return json({ error: 'Method not allowed' }, 405)

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  const authorization = request.headers.get('Authorization')
  if (!authorization) return json({ error: 'Unauthorized' }, 401)

  const callerClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
  })
  const { data: authData, error: authError } = await callerClient.auth.getUser()
  if (authError || !authData.user) return json({ error: 'Unauthorized' }, 401)

  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  })
  const { data: caller } = await adminClient
    .from('profiles')
    .select('role_id, account_status')
    .eq('user_id', authData.user.id)
    .single()
  if (caller?.role_id !== 1 || caller.account_status !== 'active') {
    return json({ error: 'Only an active admin can create users' }, 403)
  }

  let body: CreateUserBody
  try {
    body = await request.json()
  } catch (_) {
    return json({ error: 'Invalid JSON body' }, 400)
  }

  const username = body.username?.trim().toLowerCase() ?? ''
  const password = body.password ?? ''
  const fullName = body.full_name?.trim() ?? ''
  const roleId = Number(body.role_id ?? 4)
  if (!/^[a-z0-9._-]+$/.test(username)) {
    return json({ error: 'Invalid username format' }, 400)
  }
  if (password.length < 6 || fullName.length === 0) {
    return json({ error: 'Password and full name are required' }, 400)
  }
  if (![1, 2, 3, 4].includes(roleId)) {
    return json({ error: 'Invalid role' }, 400)
  }

  const divisionCode = body.division_code?.trim().toUpperCase() || 'GEN'
  const divisionName = body.division_name?.trim() || 'General'
  const { data: division, error: divisionError } = await adminClient
    .from('divisions')
    .upsert({ code: divisionCode, name: divisionName }, { onConflict: 'code' })
    .select('id, code, name')
    .single()
  if (divisionError) return json({ error: divisionError.message }, 400)

  // Auth uses a deterministic internal email so the existing username login UX
  // remains valid. A real contact email stays in profiles.contact_email.
  const authEmail = `${username}@learninghub.local`
  const { data: created, error: createError } = await adminClient.auth.admin.createUser({
    email: authEmail,
    password,
    email_confirm: true,
    user_metadata: { username, full_name: fullName, display_name: body.display_name ?? '' },
  })
  if (createError || !created.user) {
    return json({ error: createError?.message ?? 'Auth user was not created' }, 400)
  }

  const { data: profile, error: profileError } = await adminClient
    .from('profiles')
    .update({
      full_name: fullName,
      display_name: body.display_name?.trim() || fullName,
      role_id: roleId,
      division_id: division.id,
      nik: body.nik?.trim() ?? '',
      address: body.address?.trim() ?? '',
      phone: body.phone?.trim() ?? '',
      contact_email: body.contact_email?.trim() ?? '',
      education: body.education?.trim() ?? '',
      account_status: 'active',
    })
    .eq('user_id', created.user.id)
    .select('*, roles!inner(id, code), divisions(code, name)')
    .single()

  if (profileError) {
    await adminClient.auth.admin.deleteUser(created.user.id)
    return json({ error: profileError.message }, 400)
  }

  return json({ profile }, 201)
})

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}
