/*==============================================================================

								  	DIMITOR
								- Made By Heaven
								
================================================================================
=================================== Includes ===================================
==============================================================================*/

#include <a_samp>
#include <zcmd>

/*==============================================================================
=================================== Defines ====================================
==============================================================================*/

/*================================= Colors ===================================*/

#define COLOR_PINK	0xE788EEFF

/*================================ Dimitor ===================================*/

#define DIMITOR_VERSION		0.5

#define	DIMITOR             30000
#define	DIMITOR_CREATE      30001
#define	DIMITOR_EDIT        30002
#define	DIMITOR_DELETE      30003
#define	DIMITOR_SET_BONE    30004
#define	DIMITOR_SAVE        30005
#define DIMITOR_LANGUAGE	30006

#define DIMITOR_LANG_EN 	0
#define DIMITOR_LANG_FR		1

/*==============================================================================
==================================== Enums =====================================
==============================================================================*/

enum ENUM_OBJECT_DATA
{
	d_modelid,
	d_bone,
	Float:d_x,
    Float:d_y,
    Float:d_z,
    Float:d_rx,
    Float:d_ry,
    Float:d_rz,
    Float:d_sx,
    Float:d_sy,
    Float:d_sz,
	bool:d_exist
};

enum ENUM_DIMITOR_DATA
{
	d_language[MAX_PLAYERS],
	d_byname[25],
	d_projectname[33]
};

/*==============================================================================
================================== Variables ===================================
==============================================================================*/

new
	ObjectData[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS][ENUM_OBJECT_DATA],
	DimitorData[ENUM_DIMITOR_DATA];

/*==============================================================================
================================== Functions ===================================
==============================================================================*/

stock convert_encoding(string[])
{
	new original[50] = {192,193,194,196,198,199,200,201,202,203,204,205,206,207,210,211,212,214,217,218,219,220,223,224,225,226,228,230,231,232,233,234,235,236,237,238,239,242,243,244,246,249,250,251,252,209,241,191,161,176};
	new fixed[50] = {128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,94,124};
	new len = strlen(string);
	for (new i; i < len; i++)
	{
		for(new j; j < 50; j++)
		{
			if(string[i] == original[j])
			{
				string[i] = fixed[j];
				break;
			}
		}
	}
}

stock ReturnDate()
{
	new string[11], year, month, day;
	getdate(year, month, day);
	format(string, sizeof(string), "%02d/%02d/%d", day, month, year);
	return string;
}

stock ReturnTime()
{
	new string[9], hour, minute, second;
	gettime(hour, minute, second);
	format(string, sizeof(string), "%02d:%02d:%02d", hour, minute, second);
	return string;
}

GameTextForPlayerEx(playerid, string[], time, style)
{
	convert_encoding(string);
	return GameTextForPlayer(playerid, string, time, style);
}

IsLetter(const string[])
{
    for (new i = 0, j = strlen(string); i < j; i++)
    {
        if (string[i] > 'Z' || string[i] < 'A') return 0;
    }
    return 1;
}

new const GetBoneName[][][] =
{
	{
		"None", "Spine", "Head", "Left upper arm", "Right upper arm", "Left hand", "Right hand", "Left thigh", "Right thigh", "Left foot", "Right foot", "Right calf", "Left calf", "Left forearm",
		"Right forearm", "Left clavicle (shoulder)", "Right clavicle (shoulder)", "Neck", "Jaw"
	},
	{
		"Aucun", "Colonne vertébrale", "Tête", "Bras gauche", "Bras droit", "Main gauche", "Main droite", "Cuisse gauche", "Cuisse droite", "Pied gauche", "Pied droit", "Mollet droit", "Mollet gauche", "Avant-bras gauche",
		"Avant-bras droit", "Clavicule gauche (épaule)", "Clavicule droite (épaule)", "Nuque", "Mâchoire"
	}
};

CountAttachedObjectToPlayer(playerid)
{
	new count = 0;
	for(new i; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
	{
		if(!IsPlayerAttachedObjectSlotUsed(playerid, i) && !ObjectData[playerid][i][d_exist]) continue;
		count++;
	}
	return count;
}

ShowPlayerDimitor(playerid, type)
{
	new string[1025];
	switch(type)
	{
		case DIMITOR:
		{
			switch(DimitorData[d_language][playerid])
			{
				case DIMITOR_LANG_FR:
				{
					format(string, sizeof(string), "{D0D0D0}» Créer un object\n{D0D0D0}» Éditer un object\n{D0D0D0}» Supprimer un object\n{D0D0D0}» Langue\n \n{%s}» Sauvegarder", (CountAttachedObjectToPlayer(playerid) > 0 ? "2ECC71" : "E74C3C"));
					ShowPlayerDialog(playerid, DIMITOR, DIALOG_STYLE_LIST, "{E788EE}DIMITOR", string, "Valider", "Annuler");
				}
				case DIMITOR_LANG_EN:
				{
					format(string, sizeof(string), "{D0D0D0}» Create an object\n{D0D0D0}» Edit an object\n{D0D0D0}» Delete an object\n{D0D0D0}» Language\n \n{%s}» Backup", (CountAttachedObjectToPlayer(playerid) > 0 ? "2ECC71" : "E74C3C"));
					ShowPlayerDialog(playerid, DIMITOR, DIALOG_STYLE_LIST, "{E788EE}DIMITOR", string, "Confirm", "Cancel");
				}
			}
		}
		case DIMITOR_CREATE:
		{
			switch(DimitorData[d_language][playerid])
			{
				case DIMITOR_LANG_FR: ShowPlayerDialog(playerid, DIMITOR_CREATE, DIALOG_STYLE_INPUT, "{E788EE}DIMITOR » {D0D0D0}Création d'object", "Veuillez saisir le modelid de l'object.", "Valider", "Retour");
				case DIMITOR_LANG_EN: ShowPlayerDialog(playerid, DIMITOR_CREATE, DIALOG_STYLE_INPUT, "{E788EE}DIMITOR » {D0D0D0}Creation of object", "Please enter the object modelid.", "Confirm", "Back");
			}
		}
		case DIMITOR_EDIT:
		{
			if(!CountAttachedObjectToPlayer(playerid))
			{
				switch(DimitorData[d_language][playerid])
				{
					case DIMITOR_LANG_FR: SendClientMessage(playerid, COLOR_PINK, "Dimitor » {D0D0D0}Vous n'avez rien à éditer.");
					case DIMITOR_LANG_EN: SendClientMessage(playerid, COLOR_PINK, "Dimitor » {D0D0D0}You have nothing to edit.");
				}
				return ShowPlayerDimitor(playerid, DIMITOR);
			}
			switch(DimitorData[d_language][playerid])
			{
				case DIMITOR_LANG_FR: strcat(string, "Index\tModèle\tPartie du corps\n");
				case DIMITOR_LANG_EN: strcat(string, "Index\tModel\tBody part\n");
			}
			for(new i; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
			{
				if(!IsPlayerAttachedObjectSlotUsed(playerid, i)) continue;
				format(string, sizeof(string), "%s{D0D0D0}%d\t{D0D0D0}%d\t{D0D0D0}%s\n", string, i, ObjectData[playerid][i][d_modelid], GetBoneName[DimitorData[d_language][playerid]][ObjectData[playerid][i][d_bone]]);
			}
			switch(DimitorData[d_language][playerid])
			{
				case DIMITOR_LANG_FR: ShowPlayerDialog(playerid, DIMITOR_EDIT, DIALOG_STYLE_TABLIST_HEADERS, "{E788EE}DIMITOR » {D0D0D0}Édition d'object", string, "Éditer", "Retour");
				case DIMITOR_LANG_EN: ShowPlayerDialog(playerid, DIMITOR_EDIT, DIALOG_STYLE_TABLIST_HEADERS, "{E788EE}DIMITOR » {D0D0D0}Object edition", string, "Edit", "Back");
			}
		}
		case DIMITOR_DELETE:
		{
			if(!CountAttachedObjectToPlayer(playerid))
			{
				switch(DimitorData[d_language][playerid])
				{
					case DIMITOR_LANG_FR: SendClientMessage(playerid, COLOR_PINK, "Dimitor » {D0D0D0}Vous n'avez rien à supprimer.");
					case DIMITOR_LANG_EN: SendClientMessage(playerid, COLOR_PINK, "Dimitor » {D0D0D0}You have nothing to delete.");
				}
				return ShowPlayerDimitor(playerid, DIMITOR);
			}
			switch(DimitorData[d_language][playerid])
			{
				case DIMITOR_LANG_FR: strcat(string, "Index\tModèle\tPartie du corps\n");
				case DIMITOR_LANG_EN: strcat(string, "Index\tModel\tBody part\n");
			}
			for(new i; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
			{
				if(!IsPlayerAttachedObjectSlotUsed(playerid, i)) continue;
				format(string, sizeof(string), "%s{D0D0D0}%d\t{D0D0D0}%d\t{D0D0D0}%s\n", string, i, ObjectData[playerid][i][d_modelid], GetBoneName[DimitorData[d_language][playerid]][ObjectData[playerid][i][d_bone]]);
			}
			switch(DimitorData[d_language][playerid])
			{
				case DIMITOR_LANG_FR: ShowPlayerDialog(playerid, DIMITOR_DELETE, DIALOG_STYLE_TABLIST_HEADERS, "{E788EE}DIMITOR » {D0D0D0}Suppression d'object", string, "Supprimer", "Retour");
				case DIMITOR_LANG_EN: ShowPlayerDialog(playerid, DIMITOR_DELETE, DIALOG_STYLE_TABLIST_HEADERS, "{E788EE}DIMITOR » {D0D0D0}Deletion of object", string, "Delete", "Back");
			}
		}
		case DIMITOR_SET_BONE:
		{
			for(new i = 1; i < sizeof(GetBoneName[]); i++)
			{
				format(string, sizeof(string), "%s{D0D0D0}%s\n", string, GetBoneName[DimitorData[d_language][playerid]][i]);
			}
			switch(DimitorData[d_language][playerid])
			{
				case DIMITOR_LANG_FR: ShowPlayerDialog(playerid, DIMITOR_SET_BONE, DIALOG_STYLE_LIST, "{E788EE}DIMITOR » {D0D0D0}Partie du corps", string, "Valider", "Retour");
				case DIMITOR_LANG_EN: ShowPlayerDialog(playerid, DIMITOR_SET_BONE, DIALOG_STYLE_LIST, "{E788EE}DIMITOR » {D0D0D0}Body part", string, "Confirm", "Back");
			}
		}
		case DIMITOR_SAVE:
		{
			if(!CountAttachedObjectToPlayer(playerid))
			{
				switch(DimitorData[d_language][playerid])
				{
					case DIMITOR_LANG_FR: SendClientMessage(playerid, COLOR_PINK, "Dimitor » {D0D0D0}Vous n'avez rien à sauvegarder.");
					case DIMITOR_LANG_EN: SendClientMessage(playerid, COLOR_PINK, "Dimitor » {D0D0D0}You have nothing to save.");
				}
				return ShowPlayerDimitor(playerid, DIMITOR);
			}
			switch(DimitorData[d_language][playerid])
			{
				case DIMITOR_LANG_FR: ShowPlayerDialog(playerid, DIMITOR_SAVE, DIALOG_STYLE_INPUT, "{E788EE}DIMITOR » {D0D0D0}Sauvegarde", "Veuillez saisir un nom pour cette sauvegarde.", "Valider", "Retour");
				case DIMITOR_LANG_EN: ShowPlayerDialog(playerid, DIMITOR_SAVE, DIALOG_STYLE_INPUT, "{E788EE}DIMITOR » {D0D0D0}Backup", "Please enter a name for this backup.", "Confirm", "Back");
			}
		}
		case DIMITOR_LANGUAGE:
		{
			switch(DimitorData[d_language][playerid])
			{
				case DIMITOR_LANG_FR: ShowPlayerDialog(playerid, DIMITOR_LANGUAGE, DIALOG_STYLE_LIST, "{E788EE}DIMITOR » {D0D0D0}Langue", "{D0D0D0}Anglais\n{D0D0D0}Français", "Valider", "Retour");
				case DIMITOR_LANG_EN: ShowPlayerDialog(playerid, DIMITOR_LANGUAGE, DIALOG_STYLE_LIST, "{E788EE}DIMITOR » {D0D0D0}Language", "{D0D0D0}English\n{D0D0D0}French", "Confirm", "Back");
			}
		}
	}
	return 1;
}

CreateDimitorObject(playerid)
{
	for(new i; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
	{
		if(IsPlayerAttachedObjectSlotUsed(playerid, i) && ObjectData[playerid][i][d_exist]) continue;

		ObjectData[playerid][i][d_modelid] = GetPVarInt(playerid, "d_modelid");
		ObjectData[playerid][i][d_bone] = GetPVarInt(playerid, "d_boneid");
		ObjectData[playerid][i][d_x] = 0.0;
		ObjectData[playerid][i][d_y] = 0.0;
		ObjectData[playerid][i][d_z] = 0.0;
		ObjectData[playerid][i][d_rx] = 0.0;
		ObjectData[playerid][i][d_ry] = 0.0;
		ObjectData[playerid][i][d_rz] = 0.0;
		ObjectData[playerid][i][d_sx] = 0.0;
		ObjectData[playerid][i][d_sy] = 0.0;
		ObjectData[playerid][i][d_sz] = 0.0;
		ObjectData[playerid][i][d_exist] = true;

		SetPlayerAttachedObject(playerid, i, ObjectData[playerid][i][d_modelid], ObjectData[playerid][i][d_bone]);
		EditAttachedObject(playerid, i);

		return i;
	}
	return -1;
}

Log_Dimitor(playerid, file[], string[])
{
    new str[1500];
	switch(DimitorData[d_language][playerid])
	{
		case DIMITOR_LANG_FR: format(str, sizeof(str), "DIMITOR v%0.1f | Projet: %s - Par: %s - Date: %s à %s\n\n%s", DIMITOR_VERSION, DimitorData[d_projectname], DimitorData[d_byname], ReturnDate(), ReturnTime(), string);
		case DIMITOR_LANG_EN: format(str, sizeof(str), "DIMITOR v%0.1f | Project: %s - By: %s - Date: %s at %s\n\n%s", DIMITOR_VERSION, DimitorData[d_projectname], DimitorData[d_byname], ReturnDate(), ReturnTime(), string);
	}
	new File:pos = fopen(file, io_write);
    fwrite(pos, str);
    fclose(pos);
}
	
/*==============================================================================
================================== Callbacks ===================================
==============================================================================*/

public OnFilterScriptInit()
{
	print("\n--------------------------");
	print("----- Dimitor Loaded -----");
	print("--------------------------\n");
	for(new i; i <= GetPlayerPoolSize(); i++)
	{
		if(i == INVALID_PLAYER_ID) continue;
	}
	return 1;
}

public OnFilterScriptExit()
{
	for(new i; i <= GetPlayerPoolSize(); i++)
	{
		if(i == INVALID_PLAYER_ID) continue;
		for(new index; index < MAX_PLAYER_ATTACHED_OBJECTS; index++) 
		{
			if(!IsPlayerAttachedObjectSlotUsed(i, index) && !ObjectData[i][index][d_exist]) continue;
			RemovePlayerAttachedObject(i, index);
		}
	}
	print("\n--------------------------");
	print("---- Dimitor Unloaded ----");
	print("--------------------------\n");
	return 1;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new string[1500];
	switch(dialogid)
	{
		case DIMITOR:
		{
			if(response)
			{
				switch(listitem)
				{
					case 0: ShowPlayerDimitor(playerid, DIMITOR_CREATE);
					case 1: ShowPlayerDimitor(playerid, DIMITOR_EDIT);
					case 2: ShowPlayerDimitor(playerid, DIMITOR_DELETE);
					case 3: ShowPlayerDimitor(playerid, DIMITOR_LANGUAGE);
					case 4: ShowPlayerDimitor(playerid, DIMITOR);
					case 5: ShowPlayerDimitor(playerid, DIMITOR_SAVE);
				}
			}
		}
		case DIMITOR_CREATE:
		{
			if(response)
			{
				if(isnull(inputtext)) return ShowPlayerDimitor(playerid, DIMITOR_CREATE);
				SetPVarInt(playerid, "d_modelid", strval(inputtext));
				ShowPlayerDimitor(playerid, DIMITOR_SET_BONE);
			}
			else ShowPlayerDimitor(playerid, DIMITOR);
		}
		case DIMITOR_EDIT:
		{
			if(response)
			{
				EditAttachedObject(playerid, strval(inputtext));
			} 
			else ShowPlayerDimitor(playerid, DIMITOR);
		}
		case DIMITOR_DELETE:
		{
			if(response)
			{
				new index = strval(inputtext);
				RemovePlayerAttachedObject(playerid, index);
				ObjectData[playerid][index][d_exist] = false;
				switch(DimitorData[d_language][playerid])
				{
					case DIMITOR_LANG_FR: GameTextForPlayerEx(playerid, "~p~Object supprimé.", 3000, 3);
					case DIMITOR_LANG_EN: GameTextForPlayerEx(playerid, "~p~Deleted object.", 3000, 3);
				}
			}
			else ShowPlayerDimitor(playerid, DIMITOR);
		}
		case DIMITOR_SET_BONE:
		{
			if(response)
			{
				new index = -1;

				SetPVarInt(playerid, "d_boneid", listitem += 1);

				index = CreateDimitorObject(playerid);

				if(index == -1)
				{
					switch(DimitorData[d_language][playerid])
					{
						case DIMITOR_LANG_FR: SendClientMessage(playerid, COLOR_PINK, "Dimitor » {D0D0D0}Création impossible. Tous les index sont occupés.");
						case DIMITOR_LANG_EN: SendClientMessage(playerid, COLOR_PINK, "Dimitor » {D0D0D0}Impossible to create. All indexes are occupied.");
					}
					return 1;
				}

				switch(DimitorData[d_language][playerid])
				{
					case DIMITOR_LANG_FR: GameTextForPlayerEx(playerid, "~p~Object créé.", 3000, 3);
					case DIMITOR_LANG_EN: GameTextForPlayerEx(playerid, "~p~Object created.", 3000, 3);
				}
				switch(DimitorData[d_language][playerid])
				{
					case DIMITOR_LANG_FR: format(string, sizeof(string), "Dimitor » {D0D0D0}Object: %d - Partie du corps: %s - Index: %d", ObjectData[playerid][index][d_modelid], GetBoneName[DimitorData[d_language][playerid]][ObjectData[playerid][index][d_bone]], index);
					case DIMITOR_LANG_EN: format(string, sizeof(string), "Dimitor » {D0D0D0}Object: %d - Body part: %s - Index: %d", ObjectData[playerid][index][d_modelid], GetBoneName[DimitorData[d_language][playerid]][ObjectData[playerid][index][d_bone]], index);
				}
				SendClientMessage(playerid, COLOR_PINK, string);
			}
			else ShowPlayerDimitor(playerid, DIMITOR_CREATE);
		}
		case DIMITOR_SAVE:
		{
			if(response)
			{
				if(isnull(inputtext) || !IsLetter(inputtext)) return ShowPlayerDimitor(playerid, DIMITOR_SAVE);

				GetPlayerName(playerid, DimitorData[d_byname], 25);
				format(DimitorData[d_projectname], 33, inputtext);

				new projectname[65];
				format(projectname, sizeof(projectname), "Dimitor_%s.txt", inputtext);
				for(new i; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
				{
					if(!IsPlayerAttachedObjectSlotUsed(playerid, i) && !ObjectData[playerid][i][d_exist]) continue;

					format(string, sizeof(string), "%sSetPlayerAttachedObject(playerid, %d, %d, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f);\r\n",
					string, i, ObjectData[playerid][i][d_modelid], ObjectData[playerid][i][d_bone], ObjectData[playerid][i][d_x], ObjectData[playerid][i][d_y], ObjectData[playerid][i][d_z],
					ObjectData[playerid][i][d_rx], ObjectData[playerid][i][d_ry], ObjectData[playerid][i][d_rz],
					ObjectData[playerid][i][d_sx], ObjectData[playerid][i][d_sy], ObjectData[playerid][i][d_sz]);
				}
				Log_Dimitor(playerid, projectname, string);
				switch(DimitorData[d_language][playerid])
				{
					case DIMITOR_LANG_FR: GameTextForPlayerEx(playerid, "~p~Sauvegarde terminée!", 3000, 3);
					case DIMITOR_LANG_EN: GameTextForPlayerEx(playerid, "~p~Backup completed!", 3000, 3);
				}
			}
			else ShowPlayerDimitor(playerid, DIMITOR);
		}
		case DIMITOR_LANGUAGE:
		{
			if(response)
			{
				DimitorData[d_language][playerid] = listitem;
				ShowPlayerDimitor(playerid, DIMITOR_LANGUAGE);
			}
			else ShowPlayerDimitor(playerid, DIMITOR);
		}
	}
	return 1;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
    if(response)
    {
        switch(DimitorData[d_language][playerid])
		{
			case DIMITOR_LANG_FR: GameTextForPlayerEx(playerid, "~p~Édition sauvegardée.", 3000, 3);
			case DIMITOR_LANG_EN: GameTextForPlayerEx(playerid, "~p~Saved edition.", 3000, 3);
		}
		PlayerPlaySound(playerid, 1150, 0.0, 0.0, 0.0);
 
        ObjectData[playerid][index][d_x] = fOffsetX;
        ObjectData[playerid][index][d_y] = fOffsetY;
        ObjectData[playerid][index][d_z] = fOffsetZ;
        ObjectData[playerid][index][d_rx] = fRotX;
        ObjectData[playerid][index][d_ry] = fRotY;
        ObjectData[playerid][index][d_rz] = fRotZ;
        ObjectData[playerid][index][d_sx] = fScaleX;
        ObjectData[playerid][index][d_sy] = fScaleY;
        ObjectData[playerid][index][d_sz] = fScaleZ;

		SetPlayerAttachedObject(playerid, index, modelid, boneid, fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, fScaleX, fScaleY, fScaleZ);
    }
    else
    {
		switch(DimitorData[d_language][playerid])
		{
			case DIMITOR_LANG_FR: GameTextForPlayerEx(playerid, "~p~Édition annulée.", 3000, 3);
			case DIMITOR_LANG_EN: GameTextForPlayerEx(playerid, "~p~Cancelled edition.", 3000, 3);
		}
		PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
        SetPlayerAttachedObject(playerid, index, modelid, boneid, ObjectData[playerid][index][d_x], ObjectData[playerid][index][d_y], ObjectData[playerid][index][d_z], ObjectData[playerid][index][d_rx], ObjectData[playerid][index][d_ry], ObjectData[playerid][index][d_rz], ObjectData[playerid][index][d_sx], ObjectData[playerid][index][d_sy], ObjectData[playerid][index][d_sz]);
    }
    return 1;
}

/*==============================================================================
================================== Commands ====================================
==============================================================================*/

CMD:dimitor(playerid) return ShowPlayerDimitor(playerid, DIMITOR);