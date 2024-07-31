COPY (SELECT * FROM read_json('./ingest/data/source/*.json', 
        format = 'array',
        columns = {
            attachments: 'JSON',
            avatar_url: 'VARCHAR',
            created_at: 'BIGINT',
            favorited_by: 'VARCHAR[]',
            group_id: 'VARCHAR',
            id: 'VARCHAR',
            name: 'VARCHAR',
            sender_id: 'VARCHAR',
            sender_type: 'VARCHAR',
            source_guid: 'VARCHAR',
            system: 'BOOLEAN',
            text: 'VARCHAR',
            user_id: 'VARCHAR',
            platform: 'VARCHAR',
            pinned_at: 'JSON',
            pinned_by: 'VARCHAR',
            reactions: 'JSON',
            event: 'JSON',
            deleted_at: 'BIGINT',
            deletion_actor: 'VARCHAR'
        }
    )
) TO './ingest/data/formatted/8860110_history.json';
